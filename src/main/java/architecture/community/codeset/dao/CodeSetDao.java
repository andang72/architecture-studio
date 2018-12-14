package architecture.community.codeset.dao;

import java.util.List;

import architecture.community.codeset.CodeSet;
import architecture.community.model.ModelObjectTreeWalker;

public interface CodeSetDao {
	
	public void batchInsertCodeSet(List<CodeSet> codesets);

    public void saveOrUpdateCodeSet(List<CodeSet> codesets);

    public void saveOrUpdateCodeSet(CodeSet codeset);

    public CodeSet getCodeSetById(long codesetId);    
    
    public int getCodeSetCount(int objectType, long objectId);

    public List<Long> getCodeSetIds(int objectType, long objectId);
    

    public int getCodeSetCount(int objectType, long objectId, Long parentCodeSetId);

    public List<Long> getCodeSetIds(int objectType, long objectId, Long parentCodeSetId);

    
    public ModelObjectTreeWalker getTreeWalker(int objectType, long objectId);

    /**
     * 그룹 코드에 해당하는 코드 세트 수를 리턴한다.
     * 
     * @param objectType
     * @param objectId
     * @param groupCode
     * @return
     */
    public int getCodeSetCount(int objectType, long objectId, String groupCode);
    
    /**
     * 그룹 코드에 해당하는 코드세트 아이디를 리턴한다.
     * 
     * @param objectType
     * @param objectId
     * @param groupCode
     * @return
     */
    public List<Long> getCodeSetIds(int objectType, long objectId, String groupCode);
    
    /**
     * 코드에 해당하는 코드 세트 수를 리턴한다.
     * 
     * @param objectType
     * @param objectId
     * @param groupCode
     * @return
     */
    public int getCodeSetCount(int objectType, long objectId, String group, String code);
    
    /**
     * 코드에 해당하는 코드세트 아이디를 리턴한다.
     * 
     * @param objectType
     * @param objectId
     * @param groupCode
     * @return
     */
    public List<Long> getCodeSetIds(int objectType, long objectId, String group, String code);
    
    
    public Long findCodeSetByCode(int objectType, long objectId, String group, String code);
    
}
