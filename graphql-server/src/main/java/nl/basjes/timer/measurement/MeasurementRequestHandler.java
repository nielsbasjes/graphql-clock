package nl.basjes.timer.measurement;

import graphql.GraphQLError;
import graphql.schema.DataFetchingEnvironment;
import lombok.extern.log4j.Log4j2;
import org.springframework.graphql.data.method.annotation.Argument;
import org.springframework.graphql.data.method.annotation.GraphQlExceptionHandler;
import org.springframework.graphql.data.method.annotation.QueryMapping;
import org.springframework.graphql.data.method.annotation.SubscriptionMapping;
import org.springframework.graphql.execution.ErrorType;
import org.springframework.lang.NonNull;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.stereotype.Controller;
import reactor.core.publisher.Flux;

import java.util.List;

@Controller
@EnableScheduling
@Log4j2
public class MeasurementRequestHandler {

    private final MeasurementPublisher output;

    public MeasurementRequestHandler(MeasurementPublisher output) {
        this.output = output;
    }

    @QueryMapping("measurement")
    public List<Measurement> queryMeasurement(
            @Argument("since") Long since,
            @Argument("count") Integer count
    ) {
        return output.getMeasurements(since, count);
    }

    @SubscriptionMapping("measurement")
    public Flux<Measurement> subscribeMeasurement() {
        return output.asFlux();
    }

    @GraphQlExceptionHandler
    public GraphQLError handle(@NonNull Throwable ex, @NonNull DataFetchingEnvironment environment){
        return GraphQLError
                .newError()
                .errorType(ErrorType.BAD_REQUEST)
                .message(ex.getMessage())
                .path(environment.getExecutionStepInfo().getPath())
                .location(environment.getField().getSourceLocation())
                .build();
    }
}
