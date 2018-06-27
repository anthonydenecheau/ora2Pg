FROM debian:stretch-slim
 
LABEL description="Ora2Pg image"
MAINTAINER Anthony DENECHEAU <anthony.denecheau@centrale-canine.fr>

#
# 1. Declaration Variables
ENV JAVA_DIR="/usr/lib/jvm"
ENV ORACLE_DIR="/usr/lib/oracle/11.2/client64"
ENV ORA2PG_DIR="/usr/lib/ora2pg"
ENV TMP_DIR="/tmp"

#
# 2. Installation librairies
RUN echo "deb http://deb.debian.org/debian stretch main" > /etc/apt/sources.list \
&& echo "deb http://deb.debian.org/debian stretch-updates main" >> /etc/apt/sources.list \
&& echo "deb http://security.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list \
&& echo "deb-src  http://deb.debian.org/debian  stretch main" >> /etc/apt/sources.list \
&& echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
&& apt-get update && apt-get install -y --no-install-recommends curl \
 gnupg2 \
 libaio1 \
 alien \
 libdbi-perl \
 wget \
 ca-certificates \
&& wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
&& apt-get update \
&& apt-get install -y --no-install-recommends postgresql-client

#
# 3. Installation Oracle
WORKDIR $TMP_DIR

ADD assets/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm $TMP_DIR/oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm
ADD assets/oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm $TMP_DIR/oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm
ADD assets/oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm $TMP_DIR/oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm

RUN alien -i oracle-instantclient11.2-basic-11.2.0.4.0-1.x86_64.rpm \
&& alien -i oracle-instantclient11.2-sqlplus-11.2.0.4.0-1.x86_64.rpm \ 
&& alien -i oracle-instantclient11.2-devel-11.2.0.4.0-1.x86_64.rpm 

RUN echo "export ORACLE_HOME=/usr/lib/oracle/11.2/client64/" > $TMP_DIR/oracle.sh \
&& echo "export TNS_ADMIN=/usr/lib/oracle/11.2/client64/" >> $TMP_DIR/oracle.sh \
&& echo "export LD_LIBRARY_PATH=/usr/lib/oracle/11.2/client64/lib/${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" >> $TMP_DIR/oracle.sh \
&& echo "export PATH=$PATH:$ORACLE_HOME/bin" >> $TMP_DIR/oracle.sh \
&& mv $TMP_DIR/oracle.sh /etc/profile.d/oracle.sh

#
# 4. Installation Ora2Pg
RUN mkdir -p $ORA2PG_DIR
WORKDIR $ORA2PG_DIR
RUN set -x \
&& wget https://github.com/darold/ora2pg/archive/v18.2.tar.gz \
&& tar -xzf v18.2.tar.gz \
&& cd ora2pg-18.2 \
&& perl Makefile.PL \
&& make && make install \
&& . /etc/profile \
&& perl -MCPAN -e "install DBD::Oracle" 

#RUN set -x \
#	&& wget https://github.com/darold/ora2pg/archive/v18.2.tar.gz \
#	&& tar xzf v18.2.tar.gz \
#	&& cd ora2pg-18.2 \
#	&& perl Makefile.PL \
#	&& make && make install \
#	&& rm -rf v18.2.tar.gz ora2pg-18.2
#RUN set -x \
#	&& perl -MCPAN -e 'install DBI' \
#	&& perl -MCPAN -e 'install DBD::Oracle'

#
# 5. Nettoyage
RUN apt-get purge -y --auto-remove -y alien gnupg2 wget make \
&& apt-get -y clean \
&& apt-get -y autoclean  \
&& apt-get -y autoremove \
&& rm -rf "/tmp/" \
   "/var/tmp/" \
   "/var/cache/apt" \
   "/usr/share/man" \
   "/usr/share/doc" \
   "/usr/share/doc-base" \
   "/usr/share/info/*" \
   "/usr/share/groff/*" \
   "/usr/share/linda/*" \
   "/usr/share/lintian/*" \
   "/usr/share/locale/*" \
   "/var/lib/apt/lists/*"

#
# 7. Configuration
CMD ["bash"]

