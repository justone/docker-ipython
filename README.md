docker-ipython
==============

Run [IPython](http://ipython.org) inside [Docker](http://www.docker.io)

####Includes:
* [Pattern](http://www.clips.ua.ac.be/pattern)
* [NLTK](http://nltk.org)
* [Pandas](http://pandas.pydata.org)
* [NumPy](http://www.numpy.org)
* [SciPy](http://scipy.org) 
* [SymPy](http://sympy.org)
* [Cython](http://cython.org)
* [Numba](http://numba.pydata.org)
* [Biopython](http://biopython.org)
* [Rmagic](http://ipython.org/ipython-doc/dev/config/extensions/rmagic.html)
* [Scikit-learn](http://scikit-learn.org/stable/)

####Instructions
1. Build Docker image using the using ```build```.  This can take a long time, ~30mins.  Luckily this step only has to done once(or whenever you change the Dockerfile).
2. Create and shell into new Docker container using ```shell``
3. Start IPython Notebook using ```supervisord&```
4. Point your brower to ```http://<your host name>:49888```, default login password is 'password'

To run in background execute ```./start```

#### Removing or changing password authentication
In order to remove password authentication, modify the configuration in this [file](http://github.com/lluiscanet/docker-ipython/blob/master/profile_nbserver/ipython_notebook_config.py)
by commenting out the line
```c.NotebookApp.password = u'sha1:01dc1e3ecfb8:cc539c4fcc2ef3d751e4a20d918f761fd6704798'```

To change the password

1. Get your hashed password by executing in your python client the following: 

```
In [1]: from IPython.lib import passwd
In [2]: passwd()
Enter password:
Verify password:
```

2. Replace the line in config [file](http://github.com/lluiscanet/docker-ipython/blob/master/profile_nbserver/ipython_notebook_config.py) with 
```c.NotebookApp.password = u'sha1:yourhashedpassword'``` 

####Version Detail
```
>pip freeze

Bottleneck==0.7.0
Cython==0.19.2
Jinja2==2.7.1
MarkupSafe==0.18
Pattern==2.6
PyYAML==3.10
Pygments==1.6
argparse==1.2.1
beautifulsoup4==4.3.2
biopython==1.63
distribute==0.7.3
html5lib==0.99
ipython==1.1.0
llvmmath==0.1.1
llvmpy==unknown
lxml==2.3.2
matplotlib==1.3.1
medusa==0.5.4
meld3==0.6.5
networkx==1.8.1
nltk==2.0.4
nose==1.3.0
numba==0.11.0
numexpr==2.2.2
numpy==1.7.1
pandas==0.12.0
patsy==0.2.1
pymc==2.3
pyparsing==2.0.1
python-dateutil==2.2
pytz==2013.8
pyzmq==14.0.1
scipy==0.13.2
six==1.4.1
statsmodels==0.5.0
supervisor==3.0a8
sympy==0.7.4.1
tornado==3.1.1
wsgiref==0.1.2

```

Also includes 0MQ 4.0.3 and LLVM 3.2
