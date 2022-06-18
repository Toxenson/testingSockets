//
//  BirdsPresenter.swift
//  testingBirds
//
//  Created by Тоха on 18.06.2022.
//

import Foundation

protocol BasePresenter {
    func getData()
}

protocol PresenterOutput: AnyObject {
    func setNewData(_ data: String)
}

final class BirdsPresenter: BasePresenter {
    
    
    weak var output: PresenterOutput?
    private var birdsService: BirdsService?
    
    init() {
        let service = BirdsServiceImpl()
        service.delegate = self
        service.connect()
        birdsService = service
    }
    
    func getData() {
        birdsService?.getBirdInfo()
    }
}

extension BirdsPresenter: SocketDelegate {
    func socketDataReceived(result: String?) {
        guard let result = result else {
            print("result is nill")
            return
        }
        print(result)
        output?.setNewData(result)
    }
    
    func receivedNil() {
        print("recived is nill")
    }
}

