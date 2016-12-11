import Foundation

/**
 This store act as a simple wrapper that call the wrapped store on the given queue
 */
open class QueueSpecificStore<State: StateType>: StoreType {

    // MARK: Properties
    private let queue: DispatchQueue
    private let wrappedStore: Store<State>

    public var state: State! {
        return wrappedStore.state
    }

    public var dispatchFunction: DispatchFunction! {
        return wrappedStore.dispatchFunction
    }

    // MARK: Initializers
    public required init(reducer: @escaping Reducer<State>, state: State?) {
        fatalError("Should not call this initializer")
    }

    public required init(reducer: @escaping Reducer<State>,
                         state: State?,
                         middleware: [Middleware]) {
        fatalError("Should not call this initializer")
    }

    public init(wrapped store: Store<State>, queue: DispatchQueue) {
        self.wrappedStore = store
        self.queue = queue
    }

    // MARK: Subscribing
    public func subscribe<S: StoreSubscriber>(_ subscriber: S)
        where S.StoreSubscriberStateType == State {
            wrappedStore.subscribe(subscriber)
    }

    public func subscribe<SelectedState, S: StoreSubscriber>
        (_ subscriber: S, selector: ((State) -> SelectedState)?)
        where S.StoreSubscriberStateType == SelectedState {
            wrappedStore.subscribe(subscriber, selector: selector)
    }

    public func unsubscribe(_ subscriber: AnyStoreSubscriber) {
        wrappedStore.unsubscribe(subscriber)
    }

    // MARK: Dispatching
    public func dispatch(_ action: Action) -> Any {
        return queue.sync {
            return wrappedStore.dispatch(action)
        }
    }

    public func dispatch(_ actionCreator: @escaping ActionCreator) -> Any {
        return queue.sync {
            return wrappedStore.dispatch(actionCreator)
        }
    }

    public func dispatch(_ asyncActionCreator: @escaping AsyncActionCreator) {
        return queue.sync {
            return wrappedStore.dispatch(asyncActionCreator)
        }
    }

    public func dispatch(_ asyncActionCreator: @escaping AsyncActionCreator,
                         callback: DispatchCallback?) {
        return queue.sync {
            return wrappedStore.dispatch(asyncActionCreator, callback: callback)
        }
    }

    // MARK: Types
    public typealias DispatchCallback = (State) -> Void

    public typealias ActionCreator = (_ state: State, _ store: Store<State>) -> Action?

    public typealias AsyncActionCreator = (
        _ state: State,
        _ store: Store<State>,
        _ actionCreatorCallback: @escaping ((ActionCreator) -> Void)
        ) -> Void
}
