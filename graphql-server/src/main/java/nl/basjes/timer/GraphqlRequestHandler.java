package nl.basjes.timer;

//import lombok.extern.slf4j.Slf4j;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.graphql.data.method.annotation.SubscriptionMapping;
import org.springframework.stereotype.Controller;
import reactor.core.publisher.Flux;

import java.time.Duration;
import java.time.Instant;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.stream.Stream;

//@Slf4j
@Controller
public class GraphqlRequestHandler {

    private static final DateTimeFormatter DTF =
            DateTimeFormatter.ISO_DATE_TIME
            .withZone(ZoneId.of("Europe/Amsterdam"));

    private String getNowString() {
        return DTF.format(Instant.now());
    }

    @QueryMapping("now")
    public String queryNow() {
        return getNowString();
    }

    @SubscriptionMapping("now")
    public Flux<String> subscribeNow() {
        return Flux
                .fromStream(Stream.generate(this::getNowString))
                .delayElements(Duration.ofSeconds(1));
    }
}
