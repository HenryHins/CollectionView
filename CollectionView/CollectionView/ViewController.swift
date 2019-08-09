//
//  ViewController.swift
//  CollectionView
//
//  Created by Henry on 11/6/2019.
//  Copyright © 2019 AppTask. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var gridCollectionView: UICollectionView!
    @IBOutlet weak var countLabel: UILabel!
    
    var itemString = [String]()
    var cellHeight: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.width
        layout.itemSize = CGSize(width: (width / 4)-0.75, height: (width / 4)-0.75)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        self.gridCollectionView.setCollectionViewLayout(layout, animated: true)
        self.gridCollectionView.alwaysBounceVertical = true
        
        self.cellHeight = layout.itemSize.height
        
        self.gridCollectionView.register(UINib(nibName: "GridCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "GridCell")
        
        for _ in 0..<10000 {
            itemString.append(self.randomString(length: 5))
        }
        
        self.countLabel.text = "\(self.itemString.count)"
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemString.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! GridCollectionViewCell
        cell.backgroundColor = .lightGray
        cell.gridLabel.text = self.itemString[indexPath.row]
        return cell
    }

    @IBAction func removeButtonTapped(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        self.gridCollectionView.scrollsToTop = false
        
        let indexPaths = self.generateRandomIndexPaths()
        
        self.gridCollectionView.scrollToItem(at: IndexPath(item: indexPaths.first?.row ?? 0, section: 0), at: .top, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            self.removeCells(atIndexPaths: indexPaths)
        }
    }
    
    func removeCells(atIndexPaths indexPaths: [IndexPath]) {
        var fullyUpdatedItemString = self.itemString
        
        var visibleRow = self.gridCollectionView.indexPathsForVisibleItems
        visibleRow = visibleRow.sorted(by: { (first, second) -> Bool in
            return first < second
        })
        
        guard let firstRow = visibleRow.first?.row, let lastRow = visibleRow.last?.row else {
            return
        }
        
        var indexPathsToRemove = [IndexPath]()
        
        for (_, indexPath) in indexPaths.enumerated().reversed() {
            if indexPath.row >= firstRow, indexPath.row <= lastRow {
                indexPathsToRemove.append(indexPath)
                self.itemString.remove(at: indexPath.row)
            }
            fullyUpdatedItemString.remove(at: indexPath.row)
        }
        
        self.gridCollectionView.performBatchUpdates({
            self.gridCollectionView.deleteItems(at: indexPathsToRemove)
        }, completion: { (_) in
            
            self.itemString = fullyUpdatedItemString
            self.gridCollectionView.reloadData()
            
            self.countLabel.text = "\(self.itemString.count)"
            self.view.isUserInteractionEnabled = true
            self.gridCollectionView.scrollsToTop = true
        })
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        self.view.isUserInteractionEnabled = false
        self.gridCollectionView.scrollsToTop = false
        
        let indexPaths = self.generateRandomIndexPaths()
        
        self.gridCollectionView.scrollToItem(at: IndexPath(item: indexPaths.first?.row ?? 0, section: 0), at: .top, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            self.addCells(atIndexPaths: indexPaths)
        }
    }
    
    func addCells(atIndexPaths indexPaths: [IndexPath]) {
        var fullyUpdatedItemString = self.itemString
        
        var visibleRow = self.gridCollectionView.indexPathsForVisibleItems
        visibleRow = visibleRow.sorted(by: { (first, second) -> Bool in
            return first < second
        })
        
        guard let firstRow = visibleRow.first?.row, let lastRow = visibleRow.last?.row else {
            return
        }
        
        var indexPathsToInsert = [IndexPath]()
        
        for indexPath in indexPaths {
            let randomString = self.randomString(length: 5)
            
            if indexPath.row >= firstRow, indexPath.row <= lastRow {
                indexPathsToInsert.append(indexPath)
                self.itemString.insert(randomString, at: indexPath.row)
            }
            
            fullyUpdatedItemString.insert(randomString, at: indexPath.row)
        }
        
        self.gridCollectionView.performBatchUpdates({
            self.gridCollectionView.insertItems(at: indexPathsToInsert)
        }, completion: { (_) in
            
            self.itemString = fullyUpdatedItemString
            self.gridCollectionView.reloadData()
            
            self.countLabel.text = "\(self.itemString.count)"
            self.view.isUserInteractionEnabled = true
            self.gridCollectionView.scrollsToTop = true
        })
    }
    
    func generateRandomIndexPaths() -> [IndexPath] {
        var indexPaths = [IndexPath]()
        for number in self.getRandomNumbers(maxNumber: self.itemString.count-1, listSize: self.itemString.count/70) {
            indexPaths.append(IndexPath(item: number, section: 0))
        }
        return indexPaths.sorted(by: { (first, second) -> Bool in
            first < second
        })
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func getRandomNumbers(maxNumber: Int, listSize: Int)-> [Int] {
        precondition(listSize < maxNumber, "Cannot generate a list of \(listSize) unique numbers, if they all have to be less than \(maxNumber)")
        
        var randomNumbers = (array: [Int](), set: Set<Int>())
        
        while randomNumbers.set.count < listSize {
            let randomNumber = Int(arc4random_uniform(UInt32(maxNumber+1)))
            if randomNumbers.set.insert(randomNumber).inserted { // If the number is unique
                randomNumbers.array.append(randomNumber) // then also add it to the arary
            }
        }
        
        return randomNumbers.array
    }
    
}

