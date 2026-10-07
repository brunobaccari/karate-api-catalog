package portfolio;

import io.karatelabs.core.Runner;
import io.karatelabs.core.SuiteResult;
import org.junit.jupiter.api.Test;

import java.io.Reader;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Properties;

import static org.junit.jupiter.api.Assertions.assertTrue;

class CatalogTest {
    @Test
    void catalogContract() throws Exception {
        Properties config = new Properties();
        Path file = Path.of(".env");
        if (Files.exists(file)) {
            try (Reader reader = Files.newBufferedReader(file, StandardCharsets.UTF_8)) {
                config.load(reader);
            }
        }
        String baseUrl = System.getenv().getOrDefault("API_BASE_URL", config.getProperty("API_BASE_URL", ""));
        if (baseUrl.isBlank()) {
            throw new IllegalArgumentException("Set API_BASE_URL or copy .env.example to .env");
        }
        SuiteResult result = Runner.path("classpath:catalog")
                .systemProperty("api.baseUrl", baseUrl)
                .outputHtmlReport(true)
                .outputJunitXml(true)
                .parallel(1);
        assertTrue(result.isPassed(), "Catalog checks failed; see target/karate-reports");
    }
}
