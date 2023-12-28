package nl.basjes.timer.measurement;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Sinks;

@Configuration
public class SubscriptionConfig {

    @Bean
    public Sinks.Many<Measurement> sink() {
        return Sinks.many()
                .multicast()
                .directBestEffort();
//        .onBackpressureBuffer(Queues.SMALL_BUFFER_SIZE, false);
    }

    @Bean
    public Flux<Measurement> flux() {
        return sink().asFlux();
    }

}
