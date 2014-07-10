FROM ubuntu:14.04
 
RUN echo 'deb http://archive.ubuntu.com/ubuntu trusty main universe' > /etc/apt/sources.list && \
    echo 'deb http://archive.ubuntu.com/ubuntu trusty-updates universe' >> /etc/apt/sources.list 
#   echo 'deb http://archive.ubuntu.com/ubuntu trusty-security universe' >> /etc/apt/sources.list && \
#   echo 'deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty main' >> /etc/apt/sources.list && \
#   echo 'deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty' main >> /etc/apt/sources.list

#Prevent daemon start during install
RUN dpkg-divert --local --rename --add /sbin/initctl && ln -s /bin/true /sbin/initctl -f
RUN apt-get update

#Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y supervisor && mkdir -p /var/log/supervisor

#SSHD
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server &&	mkdir /var/run/sshd && \
	echo 'root:root' |chpasswd

#Utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y vim less net-tools inetutils-ping curl git telnet nmap socat dnsutils netcat

#Required by Python packages
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential python-dev python-pip liblapack-dev libatlas-dev gfortran libfreetype6 libfreetype6-dev libpng12-dev python-lxml libyaml-dev g++ libffi-dev pkg-config

#0MQ
RUN cd /tmp && \
    wget http://download.zeromq.org/zeromq-4.0.3.tar.gz && \
    tar xvfz zeromq-4.0.3.tar.gz && \
    cd zeromq-4.0.3 && \
    ./configure && \
    make install && \
    ldconfig

RUN export PIP_DEFAULT_TIMEOUT=600
#Upgrade pip
RUN pip install -U setuptools
RUN pip install -U pip
#matplotlib needs latest distribute
RUN pip install -U distribute
#IPython
RUN pip install ipython

#NumPy is required for Numba
RUN pip install numpy
#Pandas
RUN pip install pandas
#Optional
RUN ln -s /usr/local/opt/freetype/include/freetype2 /usr/local/include/freetype
RUN pip install cython
RUN pip install jinja2 pyzmq tornado
RUN pip install numexpr bottleneck scipy pygments 
RUN pip install matplotlib sympy pymc
RUN pip install patsy
RUN pip install statsmodels
RUN pip install beautifulsoup4 html5lib
#Pattern
RUN pip install --allow-external pattern pattern
#NLTK
RUN pip install pyyaml nltk
#Networkx
RUN pip install networkx
#LLVM and Numba
#RUN apt-get install -y llvm-3.3
RUN cd /tmp && \
    wget http://llvm.org/releases/3.2/llvm-3.2.src.tar.gz && \
    tar zxvf llvm-3.2.src.tar.gz && \
    cd llvm-3.2.src && \
    ./configure --enable-optimized && \
    REQUIRES_RTTI=1 make install 
#RUN pip install versioneer
#RUN versioneer-installer 
RUN pip install llvmpy==0.11.2 && \
    pip install llvmmath && \
    pip install numba
#Biopython
RUN pip install biopython
#Bokeh
#RUN pip install requests bokeh

#Install R 3+
RUN echo 'deb http://cran.rstudio.com/bin/linux/ubuntu trusty/' > /etc/apt/sources.list.d/r.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9
RUN apt-get update
RUN apt-get install -y r-base
#Rmagic
RUN pip install rpy2

#Vincent
RUN pip install vincent

#Scikit-learn
RUN pip install -U scikit-learn

#Google BigQuery
RUN pip install bigquery

#Cleanup
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#user ipy
RUN useradd -m ipy -s /bin/bash
RUN echo "ipy:ipython" | chpasswd
RUN adduser ipy sudo
RUN sudo -u ipy mkdir -p /home/ipy/bin /home/ipy/.matplotlib /home/ipy/.ipython /home/ipy/ipynotebooks /home/ipy/.ssh

ENV IPYTHONDIR /home/ipy/.ipython
ENV IPYTHON_PROFILE nbserver
RUN /usr/local/bin/ipython profile create nbserver

# Download world cup notebooks
ADD ./notebooks /home/ipy/ipynotebooks
RUN mkdir -p /etc/my_init.d
ADD notebook_clone.sh /etc/my_init.d/notebook_clone.sh

# Adding script necessary to start ipython notebook server.
ADD ./profile_nbserver/ipython_notebook_config.py /home/ipy/.ipython/profile_nbserver/ipython_notebook_config.py
RUN chown ipy:ipy /home/ipy/ -R && chmod 755  /var/run/sshd/
# fix security bug permissions
RUN cd /home/ipy/.ipython/profile_nbserver/ && mv pid pid_ && mv pid_ pid && mv security security_ && mv security_ security 

ADD ./conf /etc/supervisor/conf.d

EXPOSE 22 8888 9001

CMD ["/usr/bin/supervisord"]
