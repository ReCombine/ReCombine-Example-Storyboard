//
//  ScoreboardViewModel.swift
//  ReCombine-Scoreboard-Storyboard
//
//  Created by Kristin on 2/17/20.
//  Copyright © 2020 JohnCrowson. All rights reserved.
//

import Combine
import ReCombine

class ScoreboardViewModel {
    private let store: Store<Scoreboard.State>
    private let showAlertSubject: PassthroughSubject<Bool, Never>
    private var cancellableSet: Set<AnyCancellable> = []
    let homeScore: AnyPublisher<String, Never>
    let awayScore: AnyPublisher<String, Never>
    let showAlert: AnyPublisher<Bool, Never>
 
    init(store: Store<Scoreboard.State> = appStore) {
        self.store = store
        showAlertSubject = PassthroughSubject()
        
        homeScore = store.select(Scoreboard.getHomeScoreString)
        awayScore = store.select(Scoreboard.getAwayScoreString)
        showAlert = showAlertSubject.eraseToAnyPublisher()
        
        let showAlertEffect = Effect(dispatch: true) { actions in
            actions.ofType(Scoreboard.PostScoreSuccess.self)
                .handleEvents(receiveOutput: { [weak self] _ in
                    self?.showAlertSubject.send(true)
                })
                .map { _ in Scoreboard.ResetScore() }
                .eraseActionType()
                .eraseToAnyPublisher()
        }
        store.register(showAlertEffect).store(in: &cancellableSet)
    }
    
    func homeScoreTapped() {
        store.dispatch(action: Scoreboard.HomeScore())
    }
    
    func awayScoreTapped() {
        store.dispatch(action: Scoreboard.AwayScore())
    }
    
    func postScoreTapped() {
        Publishers.CombineLatest(homeScore, awayScore)
            .first()
            .sink { [weak self] homeScore, awayScore in
                self?.store.dispatch(action: Scoreboard.PostScore(home: homeScore, away: awayScore))
            }
            .store(in: &cancellableSet)
    }
}
