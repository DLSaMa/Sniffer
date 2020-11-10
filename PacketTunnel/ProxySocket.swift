import Foundation

/// The socket which encapsulates the logic to handle connection to proxies.
open class ProxySocket: NSObject, SocketProtocol, RawTCPSocketDelegate {
 
    public var session: ConnectSession?
    private var _cancelled = false
    var isCancelled: Bool {
        return _cancelled
    }

    open override var description: String {
        if let session = session {
            return "<\(typeName) host:\(session.host) port: \(session.port))>"
        } else {
            return "<\(typeName)>"
        }
    }

    /**
     Init a `ProxySocket` with a raw TCP socket.

     - parameter socket: The raw TCP socket.
     */
    public init(socket: RawTCPSocketProtocol, observe: Bool = true) {
        self.socket = socket

        super.init()

        self.socket.delegate = self

    }

    /**
     Begin reading and processing data from the socket.
     */
    open func openSocket() {
        guard !isCancelled else {
            return
        }

    }

    /**
     Response to the `AdapterSocket` on the other side of the `Tunnel` which has succefully connected to the remote server.

     - parameter adapter: The `AdapterSocket`.
     */
    open func respondTo(adapter: AdapterSocket) {
        guard !isCancelled else {
            return
        }

    }

    /**
     Read data from the socket.
     - warning: This should only be called after the last read is finished, i.e., `delegate?.didReadData()` is called.
     */
    open func readData() {
        guard !isCancelled else {
            return
        }

        socket.readData()
    }

    /**
     Send data to remote.

     - parameter data: Data to send.
     - warning: This should only be called after the last write is finished, i.e., `delegate?.didWriteData()` is called.
     */
    open func write(data: Data) {
        guard !isCancelled else {
            return
        }

        socket.write(data: data)
    }

    /**
     Disconnect the socket elegantly.
     */
    open func disconnect(becauseOf error: Error? = nil) {
        guard !isCancelled else {
            return
        }

        _status = .disconnecting
        _cancelled = true
        session?.disconnected(becauseOf: error, by: .proxy)
        socket.disconnect()
    }

    /**
     Disconnect the socket immediately.
     */
    open func forceDisconnect(becauseOf error: Error? = nil) {
        guard !isCancelled else {
            return
        }

        _status = .disconnecting
        _cancelled = true
        session?.disconnected(becauseOf: error, by: .proxy)
        socket.forceDisconnect()
    }

    // MARK: SocketProtocol Implementation

    /// The underlying TCP socket transmitting data.
    public var socket: RawTCPSocketProtocol!

    /// The delegate instance.
    weak public var delegate: SocketDelegate?

    var _status: SocketStatus = .established
    /// The current connection status of the socket.
    public var status: SocketStatus {
        return _status
    }

    // MARK: RawTCPSocketDelegate Protocol Implementation
    /**
     The socket did disconnect.

     - parameter socket: The socket which did disconnect.
     */
    open func didDisconnectWith(socket: RawTCPSocketProtocol) {
        _status = .closed
        delegate?.didDisconnectWith(socket: self)
    }

    /**
     The socket did read some data.

     - parameter data:    The data read from the socket.
     - parameter withTag: The tag given when calling the `readData` method.
     - parameter from:    The socket where the data is read from.
     */
    open func didRead(data: Data, from: RawTCPSocketProtocol) {
     
    }

    /**
     The socket did send some data.

     - parameter data:    The data which have been sent to remote (acknowledged). Note this may not be available since the data may be released to save memory.
     - parameter from:    The socket where the data is sent out.
     */
    open func didWrite(data: Data?, by: RawTCPSocketProtocol) {
    }

    /**
     The socket did connect to remote.

     - note: This never happens for `ProxySocket`.

     - parameter socket: The connected socket.
     */
    open func didConnectWith(socket: RawTCPSocketProtocol) {

    }

}
