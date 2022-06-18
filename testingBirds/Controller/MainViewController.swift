//
//  ViewController.swift
//  testingBirds
//
//  Created by Тоха on 18.06.2022.
//

import UIKit

protocol BaseController: AnyObject {
    var presenter: BasePresenter? { get set }
}

class MainViewController: UIViewController, BaseController {
    //MARK: - Properties
    var presenter: BasePresenter?
    private let birdLabel = UILabel()
    private let sendButton = UIButton()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMainView()
        configureBirdLabel()
        configureSendButton()
//        presenter?.getData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        activateConstraints()
    }
    
    //MARK: - Configure
    
    private func configureMainView() {
        view.backgroundColor = .white
    }
    
    private func configureBirdLabel() {
        birdLabel.translatesAutoresizingMaskIntoConstraints = false
        birdLabel.textAlignment = .right
        birdLabel.font = UIFont.boldSystemFont(ofSize: 16)
        birdLabel.textColor = .black
        birdLabel.text = "Fuck"
        
        view.addSubview(birdLabel)
    }
    
    private func configureSendButton() {
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Send massage", for: .normal)
        sendButton.tintColor = .white
        sendButton.layer.cornerRadius = 15
        sendButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        sendButton.backgroundColor = .red
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
        
        view.addSubview(sendButton)
    }
    
    //MARK: - Layout
    
    private func activateConstraints() {
        NSLayoutConstraint.activate(
            [
                birdLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                birdLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                
                sendButton.topAnchor.constraint(equalTo: birdLabel.bottomAnchor, constant: 16),
                sendButton.heightAnchor.constraint(equalToConstant: 40),
                sendButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
                sendButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
            ]
        )
    }
    
    //MARK: - Actions
    
    @objc
    private func didTapSendButton() {
        presenter?.getData()
    }

}

//MARK: - Extensions
extension MainViewController: PresenterOutput {
    func setNewData(_ data: String) {
        birdLabel.text = data
    }
}
