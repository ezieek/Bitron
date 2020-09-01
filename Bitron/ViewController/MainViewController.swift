//
//  ViewController.swift
//  Bitron
//
//  Created by Maciej Wołejko on 04/08/2020.
//  Copyright © 2020 Maciej Wołejko. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {

    weak var coordinator: ApplicationCoordinator?
    weak var timer: Timer?
    
    let cryptoModelArray: [CryptocurrencyModel] = []
    
    let colors = Colors()
    let initObjects = MainView()
    let reuseIdentifier = "reuseCell"
    let networking = Networking.shared
    let persistence = Persistence.shared
    var cryptoNames = [""]
    var cryptoRates = [""]
    var cryptoPreviousRates = [""]
    var assignedCryptoNames: [String] = []
    var assignedCryptoSubNames: [String] = []
    var assignedCryptoIcon: [String] = []
    var assignedCryptoPreviousRates: [String] = []
    var chosenCryptoNames: [String] = []
    var chosenCryptoRates: [String] = []
    var chosenCryptoPreviousRates: [String] = []
    var percentColors: [UIColor] = []
    var percentResult: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        initObjectsActions()
        retriveData()
        parseJSONData()
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        startTimer()
    }
        
    override func loadView() {
        super.loadView()
            
        view = initObjects
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        stopTimer()
    }
    
    func startTimer() {
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true, block: { [weak self] (_) in
            self?.parseJSONData()
            self?.updateData(title: "BTC-PLN", value: "10000.0", previousRate: "9999.0")
            print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        })
    }
    
    func stopTimer() {
        
        timer?.invalidate()
    }
    
   /* deinit {
        
        stopTimer()
    }*/
    
    func setupView() {
            
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addCryptoButtonPressed))
        view.layer.insertSublayer(colors.gradientColor, at: 0)
        navigationItem.title = "Bitron"
        navigationItem.setHidesBackButton(true, animated: true)
    }
        
    func initObjectsActions() {
            
        initObjects.mainTableView.register(MainCell.self, forCellReuseIdentifier: reuseIdentifier)
        initObjects.mainTableView.delegate = self
        initObjects.mainTableView.dataSource = self
        initObjects.mainTableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
    }
        
    @objc func addCryptoButtonPressed() {
            
        coordinator?.cryptoView()
    }
        
    func parseJSONData() {

        DispatchQueue.main.async {
                
            let urlPath = "https://api.bitbay.net/rest/trading/ticker"
            self.networking.request(urlPath) { [weak self] (result) in
                    
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let response = try decoder.decode(Crypto.self, from: data)
                           
                        self?.cryptoRates = [
                            response.items.btc.rate,
                            response.items.eth.rate,
                            response.items.ltc.rate,
                            response.items.lsk.rate,
                            response.items.alg.rate,
                            response.items.trx.rate,
                            response.items.amlt.rate,
                            response.items.neu.rate,
                            response.items.bob.rate,
                            response.items.xrp.rate
                        ]
                        
                        self?.cryptoPreviousRates = [
                            response.items.btc.previousRate,
                            response.items.eth.previousRate,
                            response.items.ltc.previousRate,
                            response.items.lsk.previousRate,
                            response.items.alg.previousRate,
                            response.items.trx.previousRate,
                            response.items.amlt.previousRate,
                            response.items.neu.previousRate,
                            response.items.bob.previousRate,
                            response.items.xrp.previousRate
                        ]
                        
                        
                    var currentIndex = 0
                            
                       for name in self?.chosenCryptoNames ?? [] {
                            
                            switch(name) {
                                
                            case "BTC-PLN":
                                let btcRate = response.items.btc.rate
                                let btcPreviousRate = response.items.btc.previousRate
                                self?.chosenCryptoRates[currentIndex] = btcRate
                                self?.assignedCryptoPreviousRates[currentIndex] = String(self?.percentageValue(rate: btcRate, previousRate: btcPreviousRate, index: currentIndex) ?? "")
                                self?.updateData(title: "BTC-PLN", value: btcRate, previousRate: btcPreviousRate)

                            case "ETH-PLN":
                                let ethRate = response.items.eth.rate
                                let ethPreviousRate = response.items.eth.previousRate
                                self?.chosenCryptoRates[currentIndex] = ethRate
                                self?.assignedCryptoPreviousRates[currentIndex] = String(self?.percentageValue(rate: ethRate, previousRate: ethPreviousRate, index: currentIndex) ?? "")
                                //self?.updateData(title: "ETH-PLN", value: ethRate, previousRate: ethPreviousRate)

                            case "LTC-PLN":
                                let ltcRate = response.items.ltc.rate
                                let ltcPreviousRate = response.items.ltc.previousRate
                                self?.chosenCryptoRates[currentIndex] = ltcRate
                                self?.assignedCryptoPreviousRates[currentIndex] = String(self?.percentageValue(rate: ltcRate, previousRate: ltcPreviousRate, index: currentIndex) ?? "")

                            case "LSK-PLN":
                                let lskRate = response.items.lsk.rate
                                let lskPreviousRate = response.items.lsk.previousRate
                                self?.chosenCryptoRates[currentIndex] = lskRate
                                self?.assignedCryptoPreviousRates[currentIndex] = String(self?.percentageValue(rate: lskRate, previousRate: lskPreviousRate, index: currentIndex) ?? "")

                            case "ALG-PLN":
                                let algRate = response.items.alg.rate
                                let algPreviousRate = response.items.alg.previousRate
                                self?.chosenCryptoRates[currentIndex] = algRate
                                self?.assignedCryptoPreviousRates[currentIndex] = String(self?.percentageValue(rate: algRate, previousRate: algPreviousRate, index: currentIndex) ?? "")
                                
                            case "TRX-PLN":
                                let trxRate = response.items.trx.rate
                                let trxPreviousRate = response.items.trx.previousRate
                                self?.chosenCryptoRates[currentIndex] = trxRate
                                self?.assignedCryptoPreviousRates[currentIndex] = String(self?.percentageValue(rate: trxRate, previousRate: trxPreviousRate, index: currentIndex) ?? "")
                                
                            case "AMLT-PLN":
                                let amltRate = response.items.amlt.rate
                                let amltPreviousRate = response.items.amlt.previousRate
                                self?.chosenCryptoRates[currentIndex] = amltRate
                                self?.assignedCryptoPreviousRates[currentIndex] = String(self?.percentageValue(rate: amltRate, previousRate: amltPreviousRate, index: currentIndex) ?? "")
                                
                            case "NEU-PLN":
                                let neuRate = response.items.neu.rate
                                let neuPreviousRate = response.items.neu.previousRate
                                self?.chosenCryptoRates[currentIndex] = neuRate
                                self?.assignedCryptoPreviousRates[currentIndex] = String(self?.percentageValue(rate: neuRate, previousRate: neuPreviousRate, index: currentIndex) ?? "")
                                
                            case "BOB-PLN":
                                let bobRate = response.items.bob.rate
                                let bobPreviousRate = response.items.bob.previousRate
                                self?.chosenCryptoRates[currentIndex] = bobRate
                                self?.assignedCryptoPreviousRates[currentIndex] = String(self?.percentageValue(rate: bobRate, previousRate: bobPreviousRate, index: currentIndex) ?? "")
                                
                            default:
                                let xrpRate = response.items.xrp.rate
                                let xrpPreviousRate = response.items.xrp.previousRate
                                self?.chosenCryptoRates[currentIndex] = xrpRate
                                self?.assignedCryptoPreviousRates[currentIndex] = String(self?.percentageValue(rate: xrpRate, previousRate: xrpPreviousRate, index: currentIndex) ?? "")
                            }
                            currentIndex += 1
                        }
                        

                        DispatchQueue.main.async {
                            self?.initObjects.mainTableView.reloadData()
                        }
                        
                    } catch let error {
                        print(error)
                    }
                        
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
        
    //tutaj problem jest tego typu, ze czasami jak wciskam ta sama walute
    //na CryptoViewControllerze, to tu sie pokazuje jakas inna wartosc tych walut
    //moze sprawdzic w bazie sql czy przypadkiem nie ma tam innych wartosci
    //tej samej krypto, czyli ze nasza baza nie ma duzej ilosci takich samych
    //krypto, czego nie powinno byc, bo o to tutaj chodzi
    
   /* func createData(title: String, value: String, previousRate: String) {
            
        let context = persistence.context
             
        guard let userEntity = NSEntityDescription.entity(forEntityName: "CryptoModel", in: context) else { return }
             
        let newValue = NSManagedObject(entity: userEntity, insertInto: context)
        newValue.setValue(title, forKey: "title")
        newValue.setValue(value, forKey: "value")
        newValue.setValue(previousRate, forKey: "previous")
            
        do {
            try context.save()
        } catch {
            print("Saving error")
        }
    }*/
    
    func retriveData() {
            
        let context = persistence.context
            
        let fetchRequest = NSFetchRequest<CryptocurrencyModel>(entityName: "CryptocurrencyModel")
                
        do {
            let results = try context.fetch(fetchRequest)
                    
            for result in results {
                    
                guard let readTitle = result.title else { return }
                chosenCryptoNames.append(readTitle)
                    
                guard let readValue = result.value else { return }
                chosenCryptoRates.append(readValue)
                    
                guard let readPreviousRates = result.previous else { return }
                chosenCryptoPreviousRates.append(readPreviousRates)
            }
                
            for name in chosenCryptoNames {
                
                switch(name) {
                    
                case "BTC-PLN":
                    assignedCryptoNames.append("Bitcoin")
                    assignedCryptoSubNames.append("BTC")
                    assignedCryptoIcon.append("btc")
                    assignedCryptoPreviousRates.append(contentsOf: chosenCryptoPreviousRates)
                    percentColors.append(.clear)
                    
                case "ETH-PLN":
                    assignedCryptoNames.append("Ethereum")
                    assignedCryptoSubNames.append("ETH")
                    assignedCryptoIcon.append("eth")
                    assignedCryptoPreviousRates.append(contentsOf: chosenCryptoPreviousRates)
                    percentColors.append(.clear)
                    
                case "LTC-PLN":
                    assignedCryptoNames.append("Litecoin")
                    assignedCryptoSubNames.append("LTC")
                    assignedCryptoIcon.append("litecoin")
                    assignedCryptoPreviousRates.append(contentsOf: chosenCryptoPreviousRates)
                    percentColors.append(.clear)
                    
                case "LSK-PLN":
                    assignedCryptoNames.append("Lisk")
                    assignedCryptoSubNames.append("LSK")
                    assignedCryptoIcon.append("bitcoin")
                    assignedCryptoPreviousRates.append(contentsOf: chosenCryptoPreviousRates)
                    percentColors.append(.clear)
                    
                case "ALG-PLN":
                    assignedCryptoNames.append("Algory")
                    assignedCryptoSubNames.append("ALG")
                    assignedCryptoIcon.append("bitcoin")
                    assignedCryptoPreviousRates.append(contentsOf: chosenCryptoPreviousRates)
                    percentColors.append(.clear)
                    
                case "TRX-PLN":
                    assignedCryptoNames.append("Tron")
                    assignedCryptoSubNames.append("TRX")
                    assignedCryptoIcon.append("bitcoin")
                    assignedCryptoPreviousRates.append(contentsOf: chosenCryptoPreviousRates)
                    percentColors.append(.clear)
                    
                case "AMLT-PLN":
                    assignedCryptoNames.append("AMLT")
                    assignedCryptoSubNames.append("AMLT")
                    assignedCryptoIcon.append("bitcoin")
                    assignedCryptoPreviousRates.append(contentsOf: chosenCryptoPreviousRates)
                    percentColors.append(.clear)
                    
                case "NEU-PLN":
                    assignedCryptoNames.append("Neumark")
                    assignedCryptoSubNames.append("NEU")
                    assignedCryptoIcon.append("bitcoin")
                    assignedCryptoPreviousRates.append(contentsOf: chosenCryptoPreviousRates)
                    percentColors.append(.clear)

                case "BOB-PLN":
                    assignedCryptoNames.append("Bobs repair")
                    assignedCryptoSubNames.append("BOB")
                    assignedCryptoIcon.append("bitcoin")
                    assignedCryptoPreviousRates.append(contentsOf: chosenCryptoPreviousRates)
                    percentColors.append(.clear)
                    
                default:
                    assignedCryptoNames.append("Ripple")
                    assignedCryptoSubNames.append("XRP")
                    assignedCryptoIcon.append("bitcoin")
                    assignedCryptoPreviousRates.append(contentsOf: chosenCryptoPreviousRates)
                    percentColors.append(.clear)
                    
                }
            }
            
            DispatchQueue.main.async {
                self.initObjects.mainTableView.reloadData()
            }
                
        } catch {
            print("Could not retrive data")
        }
    }
    
    func percentageValue(rate: String, previousRate: String, index: Int) -> String {
        
        let percentValue = (previousRate as NSString).doubleValue * 100 / (rate as NSString).doubleValue
        percentResult = 100 - percentValue
        
        if percentResult < 0 {
            percentResult = percentResult * (-1)
            percentColors.insert(.red, at: index)
        } else {
            percentColors.insert(.green, at: index)
        }
        
        return String(format: "%.2f", percentResult)
    }
    
    func deleteData(index: IndexPath) {
               
        let context = persistence.context
               
        let fetchRequest = NSFetchRequest<CryptocurrencyModel>(entityName: "CryptocurrencyModel")
               
        fetchRequest.predicate = NSPredicate(format: "title = %@", chosenCryptoNames[index.row] as CVarArg)
        fetchRequest.predicate = NSPredicate(format: "value = %@", chosenCryptoRates[index.row])
        fetchRequest.predicate = NSPredicate(format: "previous = %@", chosenCryptoPreviousRates[index.row] as CVarArg)

        do {
            
            if let result = try? context.fetch(fetchRequest) {
                for object in result {
                    context.delete(object)
                }
            }

            chosenCryptoNames.remove(at: index.row)
            chosenCryptoRates.remove(at: index.row)
            chosenCryptoPreviousRates.remove(at: index.row)
            initObjects.mainTableView.deleteRows(at: [index], with: .fade)

            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }
    
    func updateData(title: String, value: String, previousRate: String) {
        
        /*let context = persistence.context
             
        let fetchRequest = NSFetchRequest<CryptocurrencyModel>(entityName: "CryptocurrencyModel")
        
        fetchRequest.predicate = NSPredicate(format: "title = %@", title as CVarArg)
        fetchRequest.predicate = NSPredicate(format: "value = %@", value)
        fetchRequest.predicate = NSPredicate(format: "previous = %@", previousRate as CVarArg)
        
        do {
            let result = try context.fetch(fetchRequest)
            for object in result {
                object.setValue(title, forKey: "title")
                object.setValue(value, forKey: "value")
                object.setValue(previousRate, forKey: "previous")
                //print(object)
                //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
            }*/
        //cryptoModelArray.
          /*  do {
                try context.save()
            } catch {
                print("Saving error")
            }
            
        } catch {
            print(error)
        }*/
    }
}

extension MainViewController: UITableViewDataSource {
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            
        return chosenCryptoNames.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
        guard let cell = initObjects.mainTableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? MainCell else { return UITableViewCell() }
        
        cell.textLabel?.text = assignedCryptoNames[indexPath.row]
        cell.detailTextLabel?.text = assignedCryptoSubNames[indexPath.row]
        cell.imageView?.image = UIImage(named: assignedCryptoIcon[indexPath.row])
        cell.cryptoValueLabel.text = "\(chosenCryptoRates[indexPath.row])  PLN"
        cell.cryptoSubValueLabel.textColor = percentColors[indexPath.row]
        cell.cryptoSubValueLabel.text = "\(assignedCryptoPreviousRates[indexPath.row]) %"
        return cell
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        deleteData(index: indexPath)
        //coordinator?.detailView(name: chosenCryptoNames[indexPath.row], rate: chosenCryptoRates[indexPath.row])
            //.detailView(to: chosenCryptoNames[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
}

