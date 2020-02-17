//
//  ScoreboardViewController.swift
//  ReCombine-Scoreboard-Storyboard
//
//  Created by Kristin on 2/17/20.
//  Copyright © 2020 JohnCrowson. All rights reserved.
//

import Combine
import UIKit

class ScoreboardViewController: UIViewController {
    @IBOutlet weak var homeScoreLabel: UILabel!
    @IBOutlet weak var awayScoreLabel: UILabel!
    
    private let viewModel = ScoreboardViewModel()
    private var cancellableSet: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
    }
    
    func bindViewModel() {
        viewModel.homeScore.receive(on: RunLoop.main)
            .sink { [weak self] score in
                self?.homeScoreLabel.text = score
            }
            .store(in: &cancellableSet)
                
        viewModel.awayScore.receive(on: RunLoop.main)
            .sink { [weak self] score in
                self?.awayScoreLabel.text = score
            }
            .store(in: &cancellableSet)
        
        viewModel.showAlert.receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.showAlert()
            }
            .store(in: &cancellableSet)
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Scoreboard Posted Successfully", message: "The current scoreboard will be reset.", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }

    @IBAction func homeScoreTapped(_ sender: UIButton) {
        viewModel.homeScoreTapped()
    }
    
    @IBAction func awayScoreTapped(_ sender: UIButton) {
        viewModel.awayScoreTapped()
    }
    
    @IBAction func postScoreTapped(_ sender: UIButton) {
        viewModel.postScoreTapped()
    }
}
