package architecture.community.projects;

import java.util.List;

import org.tmatesoft.svn.core.SVNDirEntry;
import org.tmatesoft.svn.core.io.SVNRepository;

public interface ScmService {
	
	/*
	 * Scm API
	 * */
	
	public abstract Scm getScmById( long scmId ) throws  ScmNotFoundException ;
	
	public abstract void deleteScm(Scm scm);
	
	public abstract void saveOrUpdateScm(Scm scm);	
	
	public SVNRepository getSVNRepository(Scm scm) ;
	
	public List<SVNDirEntry> listEntries(SVNRepository repository, String path);
	
	public String getMineType( SVNRepository repository, String path );
	
	public String getFileTypeByName(String filename) ;
	
	public String getTextFileContent( SVNRepository repository, String path );
}
