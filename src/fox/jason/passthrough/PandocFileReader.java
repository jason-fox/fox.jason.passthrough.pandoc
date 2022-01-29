package fox.jason.passthrough;

import java.io.File;
import java.io.IOException;

public class PandocFileReader extends AntTaskFileReader {

  public PandocFileReader() {
  }

  private static final String ANT_FILE = "/../process_pandoc.xml";

  @Override
  protected String runTarget(File inputFile, String title)
    throws IOException {
    return executePandoc(inputFile, title);
  }

  protected String executePandoc(File inputFile, String title)
    throws IOException {
    return executeAntTask(
      calculateJarPath(PandocFileReader.class) + ANT_FILE,
      inputFile,
      title
    );
  }
}
