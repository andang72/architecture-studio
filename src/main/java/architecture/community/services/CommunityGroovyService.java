package architecture.community.services;

import java.io.File;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.ReentrantLock;

import javax.inject.Inject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.BeanClassLoaderAware;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.context.ResourceLoaderAware;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.scripting.ScriptSource;
import org.springframework.scripting.groovy.GroovyScriptFactory;
import org.springframework.scripting.support.ResourceScriptSource;

import com.google.common.cache.CacheBuilder;
import com.google.common.cache.CacheLoader;

import architecture.ee.service.Repository;
import groovy.lang.GroovyClassLoader;

public class CommunityGroovyService implements ResourceLoaderAware , ApplicationContextAware, BeanClassLoaderAware  {
	
	public static final String INLINE_SCRIPT_PREFIX = "inline:";
	
	public static final String JDBC_SCRIPT_PREFIX = "jdbc:";
	
	private ResourceLoader resourceLoader;

	protected Logger log = LoggerFactory.getLogger(getClass().getName());
	
	private final Object scriptClassMonitor = new Object();
	
	protected ReentrantLock lock = new ReentrantLock();
	
	private ApplicationContext applicationContext = null;
	
	private GroovyClassLoader groovyClassLoader;
	
	private com.google.common.cache.LoadingCache<String, Object> scriptServiceCache = null;
	
	@Inject
	@Qualifier("repository")
	private Repository repository;
	
	public void setResourceLoader(ResourceLoader resourceLoader) {
		this.resourceLoader = resourceLoader;
	}
	
	/** Map from bean name String to ScriptSource object */
	private final Map<String, ScriptSource> scriptSourceCache = new HashMap<String, ScriptSource>();
	
	private File scriptDir;	
	
	public CommunityGroovyService() {
		
	} 
	public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
		this.applicationContext = applicationContext;
	}
	
	public void initialize(){		
		log.debug("creating cache ...");		
		scriptServiceCache = CacheBuilder.newBuilder().maximumSize(500).expireAfterAccess( 60 * 100, TimeUnit.MINUTES).build(		
				new CacheLoader<String, Object>(){			
					public Object load(String projectId) throws Exception {
						return null;
					}
				}
			);
	}	
	
	@Override
	public void setBeanClassLoader(ClassLoader classLoader) {
		this.groovyClassLoader = new GroovyClassLoader(classLoader);
	}
	
	protected synchronized File getScriptDir() {
		if(scriptDir == null)
        {
			scriptDir = repository.getFile("services-script");
			if(!scriptDir.exists())
            {
                boolean result = scriptDir.mkdir();
                if(!result)
                    log.error((new StringBuilder()).append("Unable to create script directory: '").append(scriptDir).append("'").toString());
            }
        }
        return scriptDir;
	}
	
	
	protected Resource getScriptResource(String name) {
		File file = new File(getScriptDir(), name );
		
		log.debug("get groovy file {}", file.getPath() );
		
		FileSystemResource resource = new FileSystemResource( file ) ;
		return resource;
	}
	
	protected ScriptSource convertToScriptSource(String name) {
		return new ResourceScriptSource( getScriptResource(name) );
	}
	
	protected ScriptSource getScriptSource(String name) {
		synchronized (this.scriptSourceCache) {
			ScriptSource scriptSource = this.scriptSourceCache.get(name);
			if (scriptSource == null) {
				scriptSource = convertToScriptSource(name);
				this.scriptSourceCache.put(name, scriptSource);
			}
			return scriptSource;
		}
	}
	
	public <T> T getService(String name, Class<T> requiredType, boolean usingCache ) {
		
			
		return getService(name, requiredType);
	}
	
	public <T> T getService(String name, Class<T> requiredType) { 
		GroovyScriptFactory factory = new GroovyScriptFactory(name);
		applicationContext.getAutowireCapableBeanFactory().autowireBean(factory); 
		log.debug("get groovy service {}", name ); 
		try { 
			T obj = (T) factory.getScriptedObject(getScriptSource(name), requiredType);
			applicationContext.getAutowireCapableBeanFactory().autowireBean(obj);
			return obj;
		} catch (Exception e) { 
			e.printStackTrace();
		}
		return null;
	}
	
	/*
	protected ScriptSource convertToScriptSource(String name) {
		return new ResourceScriptSource( getScriptResource(name) );
	}
	
	public View getView(ScriptSource scriptSource) {
		GroovyScriptFactory factory = new GroovyScriptFactory("");
		try {
			return (View) factory.getScriptedObject(scriptSource, View.class);
		} catch (ScriptCompilationException e) { 
			e.printStackTrace();
		} catch (IOException e) { 
			e.printStackTrace();
		}
		return null;
	}

	protected ScriptSource getScriptSource(String beanName, String scriptSourceLocator) {
		synchronized (this.scriptSourceCache) {
			ScriptSource scriptSource = this.scriptSourceCache.get(beanName);
			if (scriptSource == null) {
				scriptSource = convertToScriptSource(beanName, scriptSourceLocator, this.resourceLoader);
				this.scriptSourceCache.put(beanName, scriptSource);
			}
			return scriptSource;
		}
	}
	
	protected ScriptSource convertToScriptSource(String beanName, String scriptSourceLocator, ResourceLoader resourceLoader) {
		if (scriptSourceLocator.startsWith(INLINE_SCRIPT_PREFIX)) {
			return new StaticScriptSource(scriptSourceLocator.substring(INLINE_SCRIPT_PREFIX.length()), beanName);
		}
		else {
			return new ResourceScriptSource(resourceLoader.getResource(scriptSourceLocator));
		}
	}
	 */
}
