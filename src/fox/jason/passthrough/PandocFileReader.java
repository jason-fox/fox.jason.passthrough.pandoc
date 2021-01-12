package fox.jason.passthrough;

public class PandocFileReader extends AbstractFileReader {

  private static final String ANT_FILE = "/../process_pandoc.xml";

  @Override
  protected String getAntFile(){
    String path =  this.getJarFile().getParent();
    return path + ANT_FILE;
  }
  
  public PandocFileReader() {
    super(PandocFileReader.class);
  }
}
