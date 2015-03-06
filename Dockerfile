FROM ubuntu:14.04

ADD stage stage
RUN chmod 755 stage/*.bash
RUN cd stage; ./setup.bash

CMD ["stage/start.bash"]