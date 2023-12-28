package nl.basjes.timer.device;

import lombok.extern.log4j.Log4j2;
import nl.basjes.timer.measurement.Measurement;
import nl.basjes.timer.measurement.MeasurementPublisher;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Controller;

@Controller
@EnableScheduling
@Log4j2
public class TheRealDevice {

    private final MeasurementPublisher output;

    public TheRealDevice(MeasurementPublisher output) {
        this.output = output;
    }

    @Scheduled(fixedRateString = "${modbus.physicalDevice.pollInterval}")
    public void getNewMeasurementsFromTheRealDevice() {
        // We are not getting a real new measurement from any device.
        // Simply creating one mathematically ... sin function in this case
        long now = System.currentTimeMillis();
        float value = (float) Math.sin(now/3000.0);
        Measurement measurement = new Measurement(now, value);

        output.publish(measurement);
    }

}
