package util;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Email template handler for dynamic email generation
 * @author Pham Minh Quan
 */
public class EmailTemplate {
    private String templateContent;
    private Map<String, String> variables;
    private static final Pattern VARIABLE_PATTERN = Pattern.compile("\\$\\{([^}]+)\\}");

    public EmailTemplate(String templateContent) {
        this.templateContent = templateContent;
        this.variables = new HashMap<>();
    }

    public EmailTemplate addVariable(String key, String value) {
        this.variables.put(key, value != null ? value : "");
        return this;
    }

    public EmailTemplate addVariable(String key, Object value) {
        this.variables.put(key, value != null ? value.toString() : "");
        return this;
    }

    public EmailTemplate addVariables(Map<String, String> vars) {
        if (vars != null) {
            this.variables.putAll(vars);
        }
        return this;
    }

    public String render() {
        String result = templateContent;
        Matcher matcher = VARIABLE_PATTERN.matcher(result);

        while (matcher.find()) {
            String variable = matcher.group(1);
            String value = variables.getOrDefault(variable, "${" + variable + "}");
            result = result.replace("${" + variable + "}", value);
            matcher = VARIABLE_PATTERN.matcher(result);
        }

        return result;
    }

    public static EmailTemplate createFromFile(String filePath) throws Exception {
        java.nio.file.Path path = java.nio.file.Paths.get(filePath);
        String content = new String(java.nio.file.Files.readAllBytes(path), "UTF-8");
        return new EmailTemplate(content);
    }
}
