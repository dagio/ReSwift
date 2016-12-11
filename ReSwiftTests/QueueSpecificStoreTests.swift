import Foundation
import XCTest
import ReSwift

class QueueSpecificStoreTests: XCTestCase {

    var baseStore: Store<TestAppState>!
    var store: QueueSpecificStore<TestAppState>!
    var reducer: TestReducer!

    override func setUp() {
        super.setUp()
        reducer = TestReducer()
        baseStore = Store(reducer: reducer.handleAction, state: TestAppState())
    }

    func testFatalErrorWhenDispatchingOnWrongQueue() {
        let actionHandledExpectation = expectation(description: "Action handled")

        let aSpecificQueue = DispatchQueue(label: "SomeQueue")
        store = QueueSpecificStore(wrapped: baseStore, queue: aSpecificQueue)

        let subscriber = TestQueueSubscriber(expectation: actionHandledExpectation)
        store.subscribe(subscriber) {
            $0.testValue
        }
        let _ = store.dispatch(SetValueAction(3))

        waitForExpectations(timeout: 1)
    }
}

class TestQueueSubscriber: StoreSubscriber {
    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func newState(state: Int?) {
        if state == nil {
            return
        }

        if currentQueueName() == "SomeQueue" {
            expectation.fulfill()
        }
    }

    private func currentQueueName() -> String? {
        let name = __dispatch_queue_get_label(nil)
        return String(cString: name, encoding: .utf8)
    }
}
