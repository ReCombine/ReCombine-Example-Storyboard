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
    
    // MARK: - Storyboard Outlets
    
    @IBOutlet weak var homeScoreLabel: UILabel!
    @IBOutlet weak var awayScoreLabel: UILabel!
    @IBOutlet weak var postScoreButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    
    private let viewModel = ScoreboardViewModel()
    private var cancellableSet: Set<AnyCancellable> = []
    
    // MARK: - Storyboard Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
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
    
    // MARK: - View Model Binding
    
    
    /// Binds UI elements to Publishers exposed by the View Model.
    /// Notice that the view controller doesn't know we are using ReCombine.
    func bindViewModel() {
        
        viewModel.homeScore
            .map { score -> String? in score }
            // ^^ this converts from the type UIImage to the type UIImage?
            // which is key to making it work correctly with the .assign()
            // operator, which must map the type *exactly*
            .receive(on: RunLoop.main)
            // ^^ and then switch to receive and process the data on the main
            // queue since we're messin with the UI
            .assign(to: \.text, on: homeScoreLabel)
            // ^^ uses the assign subscriber to update the property text
            // on a KVO compliant object, in this case yourLabel
            .store(in: &cancellableSet)
            // ^^ saving off references that can be used to cancel a pipeline.
                
        viewModel.awayScore
            .map { score -> String? in score }
            .receive(on: RunLoop.main)
            .assign(to: \.text, on: awayScoreLabel)
            .store(in: &cancellableSet)
        
        viewModel.showAPISuccessAlert.receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.showAlert()
            }
            .store(in: &cancellableSet)
        
        viewModel.apiStatus.receive(on: RunLoop.main)
            .sink { [weak self] apiStatus in
                self?.showAPIStatusView(for: apiStatus)
            }
            .store(in: &cancellableSet)
    }
    
    // MARK: - UI Helpers
    
    /// Shows an alert to tell the user we have successfully posted the score to an API.
    func showAlert() {
        let alert = UIAlertController(title: "Scoreboard Posted Successfully", message: "The current scoreboard will be reset.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Got it!", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    /// Updates the view based on the current Scoreboard API status
    func showAPIStatusView(for apiStatus: ScoreAPIStatus) {
        switch apiStatus {
            case .none:
                postScoreButton.isHidden = false
                errorLabel.isHidden = true
                activityIndicator.isHidden = true
            case .posting:
                postScoreButton.isHidden = true
                errorLabel.isHidden = true
                activityIndicator.isHidden = false
            case .error:
                postScoreButton.isHidden = true
                errorLabel.isHidden = false
                activityIndicator.isHidden = true
        }
    }
}
