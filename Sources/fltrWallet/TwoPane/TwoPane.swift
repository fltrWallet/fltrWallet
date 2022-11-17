import Combine
import SwiftUI
import Orientation

struct TwoPane<Content1: View, Content2: View>: View {
    @EnvironmentObject var orientation: Orientation.Model
    @StateObject var model = TwoPaneModel()
    
    @Environment(\.colorScheme) var color
    
    var left: (@escaping () -> Void) -> Content1
    var right: (@escaping () -> Void) -> Content2
    
    init(@ViewBuilder left: @escaping (@escaping () -> Void) -> Content1,
         @ViewBuilder right: @escaping (@escaping () -> Void) -> Content2) {
        self.left = left
        self.right = right
    }
    
    var body: some View {
        VStack {
            Group {
                ZStack {
                    left(self.model.switchRight)
                        .offset(x: model.leftX)
                    right(self.model.switchLeft)
                        .offset(x: model.rightX)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            model.startPublishers(orientation: orientation)
        }
        .onDisappear {
            model.stopPublishers()
        }
    }
}

final class TwoPaneModel: ObservableObject {
    @Published private var pane = Pane.left

    @Published fileprivate var leftX: CGFloat = 100_000
    @Published fileprivate var rightX: CGFloat = 100_000
    
    private var cancellables: Set<AnyCancellable> = []
    
    fileprivate func startPublishers(orientation: Orientation.Model) {
        $pane
            .removeDuplicates()
            .combineLatest(orientation.$size.map(\.width))
            .map { pane, width -> (CGFloat, CGFloat) in
                let left = pane.isLeft
                ? 0
                : -width
                let right = pane.isRight
                ? 0
                : width
                
                return (left, right)
            }
            .sink { value in
                withAnimation(.easeInOut) {
                    self.leftX = value.0
                    self.rightX = value.1
                }
            }
            .store(in: &cancellables)
    }
    
    var isLeft: Bool {
        self.pane.isLeft
    }
    
    var isRight: Bool {
        self.pane.isRight
    }
    
    fileprivate func stopPublishers() {
        let c = cancellables
        cancellables.removeAll()
        c.forEach { $0.cancel() }
    }
}

extension TwoPaneModel {
    func switchLeft() {
        self.pane = .left
    }
    
    func switchRight() {
        self.pane = .right
    }
    
    func `switch`() {
        self.pane = self.pane.isLeft ? .right : .left
    }
}

extension TwoPaneModel {
    enum Pane {
        case left
        case right
        
        var isLeft: Bool {
            switch self {
            case .left: return true
            case .right: return false
            }
        }
        
        var isRight: Bool {
            !isLeft
        }
    }
}
