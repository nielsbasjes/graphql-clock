package nl.basjes.timer.time;

import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.graphql.data.method.annotation.SubscriptionMapping;
import org.springframework.stereotype.Controller;
import reactor.core.publisher.Flux;

import java.time.Duration;
import java.util.stream.Stream;

@Controller
public class TimeRequestHandler {

    @QueryMapping("now")
    public Time queryNow() {
        return new Time(System.currentTimeMillis());
    }

    @SubscriptionMapping("now")
    public Flux<Time> subscribeNow() {
        return Flux
                .fromStream(Stream.generate(() -> new Time(System.currentTimeMillis())))
                .delayElements(Duration.ofSeconds(1));
    }
}
