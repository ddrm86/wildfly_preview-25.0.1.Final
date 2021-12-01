# Use custom jboss base-jdk image with openjdk 17
FROM ddrm86/jboss-jdk:17
MAINTAINER David del Río Medina <ddrm86@gmail.com>

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 25.0.1.Final
ENV WILDFLY_VERSION_PREVIEW preview-$WILDFLY_VERSION
ENV WILDFLY_SHA1 7801f8637d67115d477e2f13e0aa9270f3344381
ENV JBOSS_HOME /opt/jboss/wildfly

USER root

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN cd $HOME \
    && curl -L -O https://github.com/wildfly/wildfly/releases/download/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION_PREVIEW.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION_PREVIEW.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION_PREVIEW.tar.gz \
    && mv $HOME/wildfly-$WILDFLY_VERSION_PREVIEW $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION_PREVIEW.tar.gz \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

# Expose the ports in which we're interested
EXPOSE 8080

# Set the default command to run on boot
# This will boot WildFly in standalone mode and bind to all interfaces
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
