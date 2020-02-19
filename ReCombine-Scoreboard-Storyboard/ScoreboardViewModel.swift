//
//  ScoreboardViewModel.swift
//  ReCombine-Scoreboard-Storyboard
//
//  Created by Crowson, John on 12/10/19.
//  Copyright © 2019 Crowson, John.
//  Licensed under Apache License 2.0
//

import Combine
import Foundation
import ReCombine

class ScoreboardViewModel {
    
    // MARK: - Exposed Properties
    
    let homeScore: AnyPublisher<String, Never>
    let awayScore: AnyPublisher<String, Never>
    let apiStatus: AnyPublisher<ScoreAPIStatus, Never>
    let showAPISuccessAlert: AnyPublisher<Bool, Never>
    
    // MARK: - Internal Properties
    
    private let store: Store<Scoreboard.State>
    private let showAPISuccessAlertSubject: CurrentValueSubject<Bool, Never>
    private var cancellableSet: Set<AnyCancellable> = []

    // Adding store as a constructor parameter allows us to
    // inject a MockStore for unit testings. Adding a default
    // value eliminates the requirement of supplying it everywhere.
    init(store: Store<Scoreboard.State> = appStore) {
        
        self.store = store
        showAPISuccessAlertSubject = CurrentValueSubject(false)
        showAPISuccessAlert = showAPISuccessAlertSubject.eraseToAnyPublisher()
        
        // MARK: - Bind Properties to Selectors
        // What are selectors? See https://recombine.io/selectors
        
        homeScore = store.select(Scoreboard.getHomeScoreString)
        awayScore = store.select(Scoreboard.getAwayScoreString)
        apiStatus = store.select(Scoreboard.getAPIStatus)
        
        // MARK: - Register PostScoreSuccess Effect
        // What are (side) effects? See https://recombine.io/effects
        
        let showAlert = Effect(dispatch: true) { actions in
            actions.ofType(Scoreboard.PostScoreSuccess.self)
                .receive(on: RunLoop.main)
                .handleEvents(receiveOutput: { [weak self] _ in
                    self?.showAPISuccessAlertSubject.send(true)
                })
                .map { _ in Scoreboard.ResetScore() }
                .eraseActionType()
                .eraseToAnyPublisher()
        }
        store.register(showAlert).store(in: &cancellableSet)
    }
    
    // MARK: - Dispatch Actions as a Result of UI Events
    
    func homeScoreTapped() {
        store.dispatch(action: Scoreboard.HomeScore())
    }
    
    func awayScoreTapped() {
        store.dispatch(action: Scoreboard.AwayScore())
    }
    
    func postScoreTapped() {
        // Get the latest value for home and away score to pass into the PostScore action
        Publishers.CombineLatest(homeScore, awayScore)
            .first()
            .sink { [weak self] homeScore, awayScore in
                self?.store.dispatch(action: Scoreboard.PostScore(home: homeScore, away: awayScore))
            }
            .store(in: &cancellableSet)
    }
}
