from opencanary.modules import CanaryService

from twisted.application import internet
from twisted.web.server import Site, GzipEncoderFactory
from twisted.web.resource import Resource, EncodingResourceWrapper
from twisted.web import static

import os


class BasicResponse(Resource):
    isLeaf = True

    def __init__(self, factory):
        self.factory = factory

        with open(os.path.join(Alarmcheck.resource_dir(), "index.html")) as f:
            text = f.read()

        self.index = text.encode("utf-8")
        Resource.__init__(self)

    def render(self, request):
        logdata = {"_TYPE": "ALARMCHECK"}
        logtype = self.factory.logger.LOG_ALARMCHECK
        self.factory.log(logdata, transport=request.transport, logtype=logtype)
        request.setHeader("Server", self.factory.banner)
        return self.index


class StaticNoDirListing(static.File):
    """Web resource that serves static directory tree.
    Directory listing is not allowed, and custom headers are set.
    """

    pass


class Alarmcheck(CanaryService):
    NAME = "alarmcheck"

    def __init__(self, config=None, logger=None):
        CanaryService.__init__(self, config=config, logger=logger)
        self.port = int(config.getVal("alarmcheck.port", default=1211))
        self.staticdir = os.path.join(Alarmcheck.resource_dir(), "static")
        self.banner = config.getVal(
            "alarmcheck.banner", default="Apache/2.4.66 (Ubuntu)"
        )
        # ^ for latest see https://httpd.apache.org/
        StaticNoDirListing.BANNER = self.banner
        self.listen_addr = config.getVal("device.listen_addr", default="")

    def getService(self):
        root = StaticNoDirListing(self.staticdir)
        root.childNotFound = BasicResponse(self)
        wrapped = EncodingResourceWrapper(root, [GzipEncoderFactory()])
        site = Site(wrapped)
        return internet.TCPServer(self.port, site, interface=self.listen_addr)
