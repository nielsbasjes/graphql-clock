package nl.basjes.timer.measurement;

import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Component;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Sinks;

import java.util.List;
import java.util.TreeMap;

import static reactor.core.publisher.Sinks.EmitResult.FAIL_ZERO_SUBSCRIBER;

@Component
@Log4j2
public class MeasurementPublisherImpl implements MeasurementPublisher {

    private static final long MAX_HISTORY = 1000;
    private final TreeMap<Long, Measurement> history = new TreeMap<>();

    SubscriptionConfig config;

    public MeasurementPublisherImpl(SubscriptionConfig config) {
        this.config = config;
    }

    @Override
    public void publish(Measurement measurement) {
        log.debug("Emit : {}", measurement);
        publishToHistory(measurement);
        publishToSink(measurement);
    }

    private void publishToHistory(Measurement measurement) {
        // Store the measurement
        history.put(measurement.epoch(), measurement);

        // Prune buffer to max size
        while (history.size() > MAX_HISTORY) {
            history.pollFirstEntry();
        }
        log.debug("- History has {} entries from {} to {} ",
                history.size(),
                history.firstEntry().getKey(),
                history.lastEntry().getKey());
    }

    private void publishToSink(Measurement measurement) {
        Sinks.EmitResult emitResult = config.sink().tryEmitNext(measurement);
        if (emitResult.isFailure()) {
            if (emitResult != FAIL_ZERO_SUBSCRIBER) {
                log.error("Got an emit failure: Measurement {} --> Sinks.EmitResult {}", measurement, emitResult);
            }
        }
    }

    @Override
    public Flux<Measurement> asFlux() {
        return config.flux();
    }

    @Override
    public List<Measurement> getMeasurements(Long epoch, Integer count) {
        List<Measurement> measurements;
        if (epoch == null) {
            measurements = history.values().stream().toList();
        } else {
            measurements = history.subMap(epoch, System.currentTimeMillis()).values().stream().toList();
        }
        if (count != null && count <= measurements.size()) {
            measurements = measurements.subList( measurements.size() - count, measurements.size() );
        }
        return measurements;
    }
}
