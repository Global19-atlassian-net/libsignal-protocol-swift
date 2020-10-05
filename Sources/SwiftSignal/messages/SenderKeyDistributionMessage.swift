import SignalFfi
import Foundation

class SenderKeyDistributionMessage {
    private var handle: OpaquePointer?

    deinit {
        signal_sender_key_distribution_message_destroy(handle)
    }

    internal func nativeHandle() -> OpaquePointer? {
        return handle
    }

    init<Store: SenderKeyStore>(name: SenderKeyName, store: Store, ctx: Store.Context) throws {
        try store.withFfiStore(context: ctx) {
            try CheckError(signal_create_sender_key_distribution_message(&handle, name.nativeHandle(),
                                                                         $0, $1))
        }
    }

    init(key_id: UInt32,
         iteration: UInt32,
         chain_key: [UInt8],
         pk: PublicKey) throws {

        try CheckError(signal_sender_key_distribution_message_new(&handle,
                                                                  key_id,
                                                                  iteration,
                                                                  chain_key,
                                                                  chain_key.count,
                                                                  pk.nativeHandle()))
    }

    init(bytes: [UInt8]) throws {
        try CheckError(signal_sender_key_distribution_message_deserialize(&handle, bytes, bytes.count))
    }

    func getSignatureKey() throws -> PublicKey {
        return try invokeFnReturningPublicKey(fn: { (k) in signal_sender_key_distribution_message_get_signature_key(k, handle) })
    }

    func getId() throws -> UInt32 {
        return try invokeFnReturningInteger(fn: { (i) in signal_sender_key_distribution_message_get_id(handle, i) })
    }

    func getIteration() throws -> UInt32 {
        return try invokeFnReturningInteger(fn: { (i) in signal_sender_key_distribution_message_get_iteration(handle, i) })
    }

    func serialize() throws -> [UInt8] {
        return try invokeFnReturningArray(fn: { (b,bl) in signal_sender_key_distribution_message_serialize(handle,b,bl) })
    }

    func chain_key() throws -> [UInt8] {
        return try invokeFnReturningArray(fn: { (b,bl) in signal_sender_key_distribution_message_get_chain_key(handle,b,bl) })
    }
}
