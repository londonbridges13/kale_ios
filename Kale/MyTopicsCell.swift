//
//  MyTopicsCell.swift
//  Kale
//
//  Created by Lyndon Samual McKay on 5/21/17.
//  Copyright © 2017 Lyndon Samual McKay. All rights reserved.
//

import UIKit
import Kingfisher
import Hero
import RealmSwift

class MyTopicsCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var collectionview : UICollectionView!
    
    var topics = [Topic]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    // collection view
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.topics.count  // for handpicked articles
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell: Topic_CollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyTopic_CollectionCell", for: indexPath) as! Topic_CollectionCell
            
            cell.topicImageView.image = UIImage(named: "handpicked")
            
            cell.topicImageView.layer.shadowColor = UIColor.black.cgColor
            cell.topicImageView.layer.shadowOpacity = 1
            cell.topicImageView.layer.shadowOffset = CGSize.zero
            cell.topicImageView.layer.shadowRadius = 2
            
            cell.board.layer.cornerRadius = 4
            cell.topicImageView.layer.masksToBounds = true
            // i dont know if any of this works
            
            //            cell.topicLabel.layer.borderWidth = 1
            cell.topicLabel.layer.borderColor = UIColor.white.cgColor
            cell.topicLabel.layer.cornerRadius = 6
            
            if self.topics[indexPath.row].title != nil{
                cell.topicLabel.text = self.topics[indexPath.row].title!
            }
            
            if self.topics[indexPath.row].topic_image_url != nil{
                let url = URL(string: "\(self.topics[indexPath.row].topic_image_url!)")
                cell.topicImageView.kf.setImage(with: url)
            }
            
            return cell
        
    }

}
