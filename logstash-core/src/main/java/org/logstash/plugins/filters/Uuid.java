package org.logstash.plugins.filters;

import co.elastic.logstash.api.Configuration;
import co.elastic.logstash.api.Context;
import co.elastic.logstash.api.LogstashPlugin;
import co.elastic.logstash.api.PluginConfigSpec;
import co.elastic.logstash.api.PluginHelper;
import co.elastic.logstash.api.v0.Filter;
import org.logstash.Event;

import java.util.Arrays;
import java.util.Collection;
import java.util.UUID;

@LogstashPlugin(name = "java-uuid")
public class Uuid implements Filter {

    public static final PluginConfigSpec<String> TARGET_CONFIG =
            PluginConfigSpec.requiredStringSetting("target");

    public static final PluginConfigSpec<Boolean> OVERWRITE_CONFIG =
            PluginConfigSpec.booleanSetting("overwrite", false);

    private String id;
    private String target;
    private boolean overwrite;

    /**
     * Required constructor.
     *
     * @param id            Plugin id
     * @param configuration Logstash Configuration
     * @param context       Logstash Context
     */
    public Uuid(final String id, final Configuration configuration, final Context context) {
        this.id = id;
        this.target = configuration.get(TARGET_CONFIG);
        this.overwrite = configuration.get(OVERWRITE_CONFIG);
    }

    @Override
    public Collection<Event> filter(Collection<Event> events) {
        for (Event e : events) {
            if (overwrite || e.getField(target) == null) {
                e.setField(target, UUID.randomUUID().toString());
            }
        }
        return events;
    }

    @Override
    public Collection<PluginConfigSpec<?>> configSchema() {
        return PluginHelper.commonFilterOptions(Arrays.asList(TARGET_CONFIG, OVERWRITE_CONFIG));
    }

    @Override
    public String getId() {
        return id;
    }
}
