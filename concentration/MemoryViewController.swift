//
//  MemoryViewController.swift
//  concentration
//
//  Created by liusy182 on 25/3/16.
//  Copyright © 2016 liusy182. All rights reserved.
//

import UIKit


extension UIViewController {
    func execAfter(delay: Double, block: () -> Void) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), block)
    }
}


// MARK: UICollectionViewDelegate
extension MemoryViewController: UICollectionViewDelegate {
    
    func collectionView(
        collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if selectedIndices.contains(indexPath) {
            return
        }
        
        if selectedIndices.count == 2  {
            turnCardsFaceDown(false)
        }
        
        selectedIndices.append(indexPath)
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! CardCell
        cell.upturn()
        
        if selectedIndices.count < 2 {
            return
        }
        
        let card1 = deck[selectedIndices[0].row]
        let card2 = deck[selectedIndices[1].row]
        
        if card1 == card2 {
            numberOfPairs += 1
            checkIfFinished()
            removeCards()
        } else {
            score += 1
            turnCardsFaceDown()
        }
    }
}

// MARK: UICollectionViewDataSource
extension MemoryViewController: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return deck.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cardCell", forIndexPath: indexPath) as! CardCell
        
        let card = deck[indexPath.row]
        cell.renderCardName(card.description, backImageName: "back-1")
        
        return cell
    }
}

// MARK: Actions
private extension MemoryViewController {
    
    func checkIfFinished(){
        if numberOfPairs == deck.count/2 {
            showFinalPopUp()
        }
    }
    
    func showFinalPopUp() {
        let alert = UIAlertController(
            title: "Great!",
            message: "You won with score: \(score)!",
            preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(
            UIAlertAction(
                title: "Ok",
                style: .Default,
                handler: {
                    action in self.dismissViewControllerAnimated(true, completion: nil)
                }
            )
        )
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func removeCards(){
        self.removeCardsAtPlaces(self.selectedIndices)
        self.selectedIndices = []
    }
    
    func turnCardsFaceDown(withDelay: Bool = true){
        if withDelay {
            self.shouldTurnCardFaceDown = true;
            execAfter(1.5) {
                if !self.shouldTurnCardFaceDown {
                    return
                }
                
                self.downturnCardsAtPlaces(self.selectedIndices)
                self.selectedIndices = []
            }
        } else {
            self.shouldTurnCardFaceDown = false;
            
            self.downturnCardsAtPlaces(self.selectedIndices)
            self.selectedIndices = []

        }
    }
    
    func removeCardsAtPlaces(places: Array<NSIndexPath>){
        for index in selectedIndices {
            let cardCell = collectionView.cellForItemAtIndexPath(index) as! CardCell
            cardCell.remove()
        }
    }
    
    func downturnCardsAtPlaces(places: Array<NSIndexPath>){
        for index in selectedIndices {
            let cardCell = collectionView.cellForItemAtIndexPath(index)as! CardCell
            cardCell.downturn()
        }
    }
}


//MARK: Setup
private extension MemoryViewController {
    
    func setup() {
        view.backgroundColor = .greenSea()
        
        let space: CGFloat = 5
        let (covWidth, covHeight) =
            collectionViewSizeDifficulty(difficulty, space: space)
        
        let layout =
            layoutCardSize(
                cardSizeDifficulty(difficulty, space: space),
                space: space)
        
        collectionView = UICollectionView(
            frame: CGRect(x: 0, y: 0, width: covWidth, height: covHeight),
            collectionViewLayout: layout)
        
        collectionView.center = view.center
        
        collectionView.dataSource = self
        
        collectionView.delegate = self
        
        collectionView.scrollEnabled = false
        
        collectionView.registerClass(
            CardCell.self,
            forCellWithReuseIdentifier: "cardCell")
        
        collectionView.backgroundColor = .clearColor()
        
        self.view.addSubview(collectionView)
    }
    
    func collectionViewSizeDifficulty(
        difficulty: Difficulty, space: CGFloat) -> (CGFloat, CGFloat) {
        
        let (columns, rows) = sizeDifficulty(difficulty)
        let (cardWidth, cardHeight) =
            cardSizeDifficulty(difficulty, space: space)
        
        let covWidth = columns*(cardWidth + 2*space)
        let covHeight = rows*(cardHeight + space)
        return (covWidth, covHeight)
    }
    
    func cardSizeDifficulty(
        difficulty: Difficulty, space: CGFloat) -> (CGFloat, CGFloat) {
        
        let ratio: CGFloat = 1.452
        
        let (_, rows) = sizeDifficulty(difficulty)
        
        let cardHeight: CGFloat = view.frame.height / rows - 2 * space
        let cardWidth: CGFloat = cardHeight/ratio
        return (cardWidth, cardHeight)
    }
    
    func sizeDifficulty(difficulty: Difficulty) -> (CGFloat, CGFloat) {
        switch difficulty {
        case .Easy:
            return (4,3)
        case .Medium:
            return (6,4)
        case .Hard:
            return (8,4)
        }
    }
    
    func numCardsNeededDifficulty(difficulty: Difficulty) -> Int {
        let (columns, rows) = sizeDifficulty(difficulty)
        return Int(columns * rows)
    }
    
    func layoutCardSize(
        cardSize: (cardWidth: CGFloat, cardHeight: CGFloat), space: CGFloat)
        -> UICollectionViewLayout {
            
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset =
            UIEdgeInsets(top: space, left: space, bottom: space, right: space)
            
        layout.itemSize =
            CGSize(width: cardSize.cardWidth, height: cardSize.cardHeight)
            
        layout.minimumLineSpacing = space
        return layout
    }
    
    private func start() {
        numberOfPairs = 0
        score = 0
        deck = createDeck(numCardsNeededDifficulty(difficulty))
        for i in 0..<deck.count  {
            print("The card at index [\(i)] is [\(deck[i].description)]")
        }
        
        collectionView.reloadData()
    }
    
    private func createDeck(numCards: Int) -> Deck {
        
        let fullDeck = Deck.full().shuffled()
        
        let halfDeck = fullDeck.deckOfNumberOfCards(numCards / 2)
        
        return (halfDeck + halfDeck).shuffled()
    }
}


class MemoryViewController: UIViewController {
    
    private var deck: Deck!
    private var selectedIndices = Array<NSIndexPath>()
    private var numberOfPairs = 0
    private var score = 0
    
    private let difficulty: Difficulty
    private var collectionView: UICollectionView!
    
    var shouldTurnCardFaceDown: Bool!
    
    init(difficulty: Difficulty) {
        self.difficulty = difficulty
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit{
        print("deinit")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        start()
    }
}
