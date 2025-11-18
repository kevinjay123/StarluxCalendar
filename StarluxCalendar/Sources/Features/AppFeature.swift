import ComposableArchitecture
import SwiftUI

@Reducer
struct AppFeature {
    struct State: Equatable {
        var home: HomeFeature.State = .init()
    }
    
    enum Action {
        case home(HomeFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeFeature()
        }
        
        Reduce(core)
    }
    
    func core(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .home:
            return .none
        }
    }
}

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        HomeView(store: store.scope(state: \.home, action: \.home))
    }
}
