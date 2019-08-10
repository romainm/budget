


import sys
import os

# from PySide2.QtCore import Qt, QObject, Signal, Slot, Property
# from PySide2.QtWidgets import QApplication
from PySide2.QtQml import QQmlApplicationEngine
# from PySide2 import QtCore, QtQml
from PySide2.QtWidgets import QApplication

# from PySide2.QtQuick import QQuickView

from PySide2.QtCore import QObject, QUrl, Signal, Property, Slot

class Backend(QObject):

    @Slot('QVariantList')
    def loadFile(self, filePaths):
        print('loading files: %s' % filePaths)
        for path in filePaths:
            with open(QUrl(path).toLocalFile()) as f:
                self.parseOfx(f.read())


    def parseOfx(self, content):
        print("parsing ofx content. Length: %d" % len(content))





if __name__ == "__main__":
    # os.environ["QT_QUICK_CONTROLS_STYLE"] = "Material"
    app = QApplication(sys.argv)

    backend = Backend()

    # QtQml.qmlRegisterType(FileLoader, 'FileLoader', 1, 0, 'FileLoader')

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("backend", backend)
    # # manager = Manager()
    # # ctx = engine.rootContext()
    # # ctx.setContextProperty("Manager", manager)
    engine.load('qml/main.qml')
    # if not engine.rootObjects():
    #     sys.exit(-1)
    sys.exit(app.exec_())


    # app = QApplication(sys.argv)
    # view = QQuickView()
    # url = QUrl("main.qml")

    # view.setSource(url)
    # view.show()
    # sys.exit(app.exec_())
