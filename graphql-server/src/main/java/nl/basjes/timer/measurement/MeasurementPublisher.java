package nl.basjes.timer.measurement;

import reactor.core.publisher.Flux;

import java.util.List;

public interface MeasurementPublisher {
    /**
     * Publish a new measurement
     * @param measurement The measurement to be published
     */
    void publish(Measurement measurement);

    /**
     * Get all the future published measurements as a flux
     * @return The flux
     */
    Flux<Measurement> asFlux();

    List<Measurement> getMeasurements(Long epoch, Integer count);
}
