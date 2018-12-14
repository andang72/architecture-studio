package architecture.community.projects;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

import javax.activation.MimetypesFileTypeMap;
import javax.inject.Inject;

import org.apache.commons.io.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.tmatesoft.svn.core.SVNDirEntry;
import org.tmatesoft.svn.core.SVNException;
import org.tmatesoft.svn.core.SVNProperties;
import org.tmatesoft.svn.core.SVNProperty;
import org.tmatesoft.svn.core.SVNURL;
import org.tmatesoft.svn.core.auth.ISVNAuthenticationManager;
import org.tmatesoft.svn.core.internal.io.dav.DAVRepositoryFactory;
import org.tmatesoft.svn.core.internal.io.fs.FSRepositoryFactory;
import org.tmatesoft.svn.core.internal.io.svn.SVNRepositoryFactoryImpl;
import org.tmatesoft.svn.core.io.SVNRepository;
import org.tmatesoft.svn.core.io.SVNRepositoryFactory;
import org.tmatesoft.svn.core.wc.SVNWCUtil;

import com.google.common.cache.CacheBuilder;
import com.google.common.cache.CacheLoader;

import architecture.community.projects.dao.ProjectDao;
import architecture.ee.service.Repository;

public class CommunityScmService implements ScmService {

	private Logger logger = LoggerFactory.getLogger(getClass().getName());
	
	@Inject
	@Qualifier("projectDao")
	private ProjectDao projectDao;
	
	
	@Inject
	@Qualifier("repository")
	private Repository repository;
	
	private File scmCacheDir;	 
	
	private com.google.common.cache.LoadingCache<Long, Scm> projectScmCache = null;
	
	private com.google.common.cache.LoadingCache<Long, SVNRepository> svnRepositoryCache = null;
	
	
	public CommunityScmService() { 
	}
	
	
	protected synchronized File getTempDir() {
		
		File tempDir = repository.getFile("temp");
		if(!tempDir.exists())
        {
			boolean result = tempDir.mkdir();
            if(!result) {
                logger.error( (new StringBuilder()).append("Unable to create temp directory: '{}'").toString() , tempDir.getPath() );
            }
        } 
		return tempDir;
	}
	
	protected File getScmCacheDir(){
		
		if( scmCacheDir == null ){
			scmCacheDir = new File(getTempDir(), "scm" );	
			if(!scmCacheDir.exists())
	        {
	            boolean result = scmCacheDir.mkdir();
	            if(!result)
	            	logger.error((new StringBuilder()).append("Unable to create attachment cache directory: '{}'").toString(), scmCacheDir.getPath());
	        }
		}
		return scmCacheDir;
	}
	
	

	public void initialize(){		
		logger.debug("creating cache ...");		
		 
		projectScmCache = CacheBuilder.newBuilder().maximumSize(50).expireAfterAccess(60 * 100, TimeUnit.MINUTES).build(		
				new CacheLoader<Long, Scm>(){			
					public Scm load(Long scmId) throws Exception {
						logger.debug("loading scm by {}", scmId);
						return projectDao.getScmById(scmId);
				}}
			);
		
		svnRepositoryCache = CacheBuilder.newBuilder().maximumSize(50).expireAfterAccess(60 * 100, TimeUnit.MINUTES).build(		
				new CacheLoader<Long, SVNRepository>(){		 
					public SVNRepository load(Long scmId) throws Exception {
						SVNRepository repository = null;
						Scm scm = getScmById(scmId); 
						try {
				            /*
				             * Creates an instance of SVNRepository to work with the repository.
				             * All user's requests to the repository are relative to the
				             * repository location used to create this SVNRepository.
				             * SVNURL is a wrapper for URL strings that refer to repository locations.
				             */
				        	
				            repository = SVNRepositoryFactory.create(SVNURL.parseURIEncoded(scm.getUrl()));
				        } catch (SVNException e) {
				        	logger.error(e.getMessage(), e);
				        } 
				        ISVNAuthenticationManager authManager = SVNWCUtil.createDefaultAuthenticationManager(scm.getUsername(), scm.getPassword());
				        repository.setAuthenticationManager(authManager); 
						return repository;
				}}
			);
		setupLibrary();
	} 
	
	public Scm getScmById(long scmId) throws ScmNotFoundException {
		
		Scm scm = null;
		try {
			if( projectScmCache != null)
				scm = projectScmCache.get(scmId);
			else
				scm = projectDao.getScmById(scmId);
		} catch (Exception e) {
			throw new ScmNotFoundException(e);
		}
		return scm;
	
	}
	
	
	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void deleteScm(Scm scm) {
		
		projectDao.deleteScm(scm);
		if( projectScmCache != null)
			projectScmCache.invalidate(scm.getScmId());
	}
	
	@Transactional(readOnly = false, propagation = Propagation.REQUIRES_NEW)
	public void saveOrUpdateScm(Scm scm) {
		
		projectDao.saveOrUpdateScm(scm);
		
		if( projectScmCache != null)
			projectScmCache.refresh(scm.getScmId());
	} 
	
    private static void setupLibrary() {
        /*
         * For using over http:// and https://
         */
        DAVRepositoryFactory.setup();
        /*
         * For using over svn:// and svn+xxx://
         */
        SVNRepositoryFactoryImpl.setup();
        
        /*
         * For using over file:///
         */
        FSRepositoryFactory.setup();
    }
    
    
	public SVNRepository getSVNRepository(Scm scm) {
		try {
			return svnRepositoryCache.get(scm.getScmId());
		} catch (ExecutionException e) { 
			e.printStackTrace();
			return null;
		} 
	} 
	
	public String getFileTypeByName(String filename) {
		MimetypesFileTypeMap mimeTypesMap = new MimetypesFileTypeMap();
		return mimeTypesMap.getContentType(filename);
	}
	
	
	public String getMineType( SVNRepository repository, String path ) {
		SVNProperties fileProperties = new SVNProperties();
		ByteArrayOutputStream baos = new ByteArrayOutputStream();
		try {
			repository.getFile(path, -1, fileProperties, baos);
		} catch (SVNException e) {
			logger.error(e.getMessage());
		}
		String mimeType = fileProperties.getStringValue(SVNProperty.MIME_TYPE); 
		return mimeType;
	}
	
	
	
	public String getTextFileContent( SVNRepository repository, String path ) { 
		SVNProperties fileProperties = new SVNProperties();
	    ByteArrayOutputStream baos = new ByteArrayOutputStream();
	    try {
			repository.getFile(path, -1, fileProperties, baos);
		} catch (SVNException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	    
		String mimeType = fileProperties.getStringValue(SVNProperty.MIME_TYPE);
		boolean isTextType = SVNProperty.isTextMimeType(mimeType);
		if(  isTextType )
		try {
			return new String( baos.toByteArray() , "UTF-8");
		} catch (UnsupportedEncodingException e) {
		}
		return "";
	}
	
	public List<SVNDirEntry> listEntries(SVNRepository repository, String path) {

	        /*
	         * Gets the contents of the directory specified by path at the latest
	         * revision (for this purpose -1 is used here as the revision number to
	         * mean HEAD-revision) getDir returns a Collection of SVNDirEntry
	         * elements. SVNDirEntry represents information about the directory
	         * entry. Here this information is used to get the entry name, the name
	         * of the person who last changed this entry, the number of the revision
	         * when it was last changed and the entry type to determine whether it's
	         * a directory or a file. If it's a directory listEntries steps into a
	         * next recursion to display the contents of this directory. The third
	         * parameter of getDir is null and means that a user is not interested
	         * in directory properties. The fourth one is null, too - the user
	         * doesn't provide its own Collection instance and uses the one returned
	         * by getDir.
	         */ 
	        ArrayList<SVNDirEntry> list = new ArrayList<SVNDirEntry>(); 
	        Collection entries;
			try {
				entries = repository.getDir(path, -1, null, ( Collection ) null);
				 Iterator iterator = entries.iterator();
			        while (iterator.hasNext()) {
			            SVNDirEntry entry = (SVNDirEntry) iterator.next();
			            list.add(entry);
			        }
			} catch (SVNException e) { 
				logger.error(e.getMessage(), e);
			}  
			
			
			Collections.sort(list, new Comparator<SVNDirEntry>(){
				public int compare(SVNDirEntry o1, SVNDirEntry o2) { 
					if( o1.getKind() == o2.getKind() ) {
						return 0;
					}
					return o1.getKind().getID() - o2.getKind().getID();
				}
			});
	        return list;
	}
	 
}
