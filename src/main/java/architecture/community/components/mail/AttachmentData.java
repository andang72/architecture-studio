package architecture.community.components.mail;

import java.io.InputStream;

public class AttachmentData {

    private final String filename;
    private final InputStream is;
    private final String contentType;
    
    public AttachmentData(String filename, String contentType, InputStream is)
    {
        this.filename = filename;
        this.is = is;
        this.contentType = contentType;
    }

    public String getFilename()
    {
        return filename;
    }

    public InputStream getInputStream()
    {
        return is;
    }

    public String getContentType()
    {
        return contentType;
    }

}
