import java.net.http.*;
import java.time.Duration;

import static java.time.temporal.ChronoUnit.SECONDS;

url = args[0]

// Give enough time for 2 DNS attempts with a 1 second timeout
request = HttpRequest.newBuilder(new URI(url)).GET().timeout(Duration.of(3, SECONDS)).build();

response = null;
start = System.currentTimeMillis();
e = null;
rootCause = null;
try {
    response = HttpClient.newBuilder().build().send(request, HttpResponse.BodyHandlers.ofString());
} catch (Throwable t) {
    e = t;
    rootCause = e;
    while (rootCause.getCause() != null) {
        rootCause = rootCause.getCause();
    }
}
end = System.currentTimeMillis();

if (rootCause == null) {
    println("SUCCESS! Took " + ((end - start) / 1000) + " seconds. " + response);
} else {
    println("FAILURE! Took " + ((end - start) / 1000) + " seconds. Root cause exception: " + rootCause);
    if ("true".equals(System.getenv("DEBUG"))) {
        e.printStackTrace();
    }
}
