import java.net.http.*;
import java.time.Duration;

import static java.time.temporal.ChronoUnit.SECONDS;

// Give enough time for 2 DNS attempts with a 1 second timeout
request = HttpRequest.newBuilder(new URI("https://www.google.com/")).GET().timeout(Duration.of(3, SECONDS)).build();

start = System.currentTimeMillis();
try {
    response = HttpClient.newBuilder().build().send(request, HttpResponse.BodyHandlers.ofString());
    println("success! " + response.toString());
} catch (Throwable t) {
    t.printStackTrace();
}
end = System.currentTimeMillis();

println("took " + ((end - start) / 1000) + " seconds");
