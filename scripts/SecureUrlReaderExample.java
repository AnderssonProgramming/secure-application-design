import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;
import java.io.File;
import java.io.FileInputStream;
import java.security.KeyStore;

public class SecureUrlReaderExample {
    public static void main(String[] args) throws Exception {
        File trustStoreFile = new File("keystores/myTrustStore.p12");
        char[] trustStorePassword = "567890".toCharArray();

        KeyStore trustStore = KeyStore.getInstance(KeyStore.getDefaultType());
        try (FileInputStream fis = new FileInputStream(trustStoreFile)) {
            trustStore.load(fis, trustStorePassword);
        }

        TrustManagerFactory tmf = TrustManagerFactory.getInstance(TrustManagerFactory.getDefaultAlgorithm());
        tmf.init(trustStore);

        SSLContext sslContext = SSLContext.getInstance("TLS");
        sslContext.init(null, tmf.getTrustManagers(), null);
        SSLContext.setDefault(sslContext);

        System.out.println("TrustStore loaded. Ready to call HTTPS URLs.");
    }
}
