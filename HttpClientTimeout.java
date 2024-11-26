import java.net.URI;
import java.net.URISyntaxException;
import java.net.http.*;
import java.time.Duration;

import static java.time.temporal.ChronoUnit.SECONDS;

public class Main {
    public static void main(String[] argv) throws URISyntaxException {
        if (argv.length != 4) {
            System.err.println("Incorrect number of command-line arguments.");
            System.err.println("usage: java HttpClientTimeout.java sync|async <url> <request timeout> <connect timeout>");
            System.err.println("<request timeout> and <connect timeout> should be ISO-8601 durations (e.g.: 'PT2S') or '-'");
            System.err.println("See https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/time/Duration.html#parse(java.lang.CharSequence)");
            System.exit(1);
        }

        String mode = argv[0];
        String url = argv[1];
        String requestTimeout = argv[2];
        String connectTimeout = argv[3];

        boolean async = false;
        if ("sync".equals(mode)) {
            async = false;
        } else if ("async".equals(mode)) {
            async = true;
        } else {
            System.err.println("first argument must be either 'sync' or 'async', not '" + mode + "'");
            System.exit(1);
        }

        HttpRequest.Builder requestBuilder = HttpRequest.newBuilder(new URI(url))
            .GET();
        if (!"-".equals(requestTimeout)) {
            requestBuilder.timeout(Duration.parse(requestTimeout));
        }
        HttpRequest request = requestBuilder.build();

        HttpResponse response = null;
        long start = System.currentTimeMillis();
        Throwable e = null;
        Throwable rootCause = null;
        try {
            HttpClient.Builder clientBuilder = HttpClient.newBuilder();
            if (!"-".equals(connectTimeout)) {
                clientBuilder.connectTimeout(Duration.parse(connectTimeout));
            }
            HttpClient client = clientBuilder.build();
            if (async) {
                response = client.sendAsync(request, HttpResponse.BodyHandlers.ofString()).get();
            } else {
                response = client.send(request, HttpResponse.BodyHandlers.ofString());
            }
        } catch (Throwable t) {
            e = t;
            rootCause = e;
            while (rootCause.getCause() != null) {
                rootCause = rootCause.getCause();
            }
        }
        long end = System.currentTimeMillis();

        if (rootCause == null) {
            System.out.println(String.format("SUCCESS! Took %.03f seconds: %s", ((end - start) / 1000.0), response));
        } else {
            System.out.println(String.format("FAILURE! Took %.03f seconds: Root cause exception: %s", ((end - start) / 1000.0), rootCause));
            if ("true".equals(System.getenv("DEBUG"))) {
                e.printStackTrace();
            }
        }
    }
}
