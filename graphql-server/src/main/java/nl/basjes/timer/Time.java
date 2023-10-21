package nl.basjes.timer;

import java.time.Instant;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;

import static java.time.ZoneOffset.UTC;

public record Time(
    Integer year,
    Integer month,
    Integer day,
    Integer hour,
    Integer minute,
    Integer second,
    Integer millisecond,
    String iso) {

    public Time(long epochMs) {
        this(Instant.ofEpochMilli(epochMs));
    }

    public Time(Instant instant) {
        this(instant.atZone(UTC));
    }

    public Time(ZonedDateTime zonedDateTime) {
        this(
            zonedDateTime.getYear(),
            zonedDateTime.getMonthValue(),
            zonedDateTime.getDayOfMonth(),
            zonedDateTime.getHour(),
            zonedDateTime.getMinute(),
            zonedDateTime.getSecond(),
            zonedDateTime.getNano()/1_000_000,
            DateTimeFormatter.ISO_DATE_TIME.format(zonedDateTime)
        );
    }
}
