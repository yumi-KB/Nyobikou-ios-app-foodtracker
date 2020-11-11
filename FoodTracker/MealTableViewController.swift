//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by yumi kanebayashi on 2020/10/21.
//

import UIKit
import os.log

class MealTableViewController: UITableViewController {
    
    // MARK: Properties
    var meals = [Meal]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        // Load any saved meals, otherwise load sample data.
        // loadMealsの配列もしくは単体データを　meals配列に追加
        if let savedMeals = loadMeals() {
            meals += savedMeals
        } else {
            // Load the sample data.
            loadSampleMeals()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
        // 1セクションに表示
    }

    // 1Sectionに対する行数　mealscountの数だけ
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return meals.count
    }

    // 1行あたりの表示セル詳細
    // 表示セル詳細
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeud using a cell indentifier
        // セルの型
        let cellIdentifier = "MealTableViewCell"
        
        // セルをリサイクルして取得するメソッドdequeueReusableCell(withIdentifier:for:)
        // が MealTableViewCellにダウンキャスト　変換できるか？
        // withIdentifier cellの型指定
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell else {
            fatalError("The dequeued cell is not instance of MealTableViewCell.")
        }
        
        // セル取得　もしリサイクルできるのであればする　できなければ新規セル作成
        // データを取得して表示
        // Fetches the appropriate meals for the data source layout.
        let meal = meals[indexPath.row]
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating

        return cell
    }
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     // guard cellIdentifier="" as? MealTableViewCell
     
         // Configure the cell...

         return cell
     }
     */

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            // Delete the row from the data source
            meals.remove(at: indexPath.row)
            // 削除
            saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        
        // nil結合演算子　nilの場合、空文字””に変換
        switch segue.identifier ?? "" {
        case "AddItem":
            os_log("Adding a new meal.", log: .default, type: .debug)
        case "ShowDetail":
            guard let mealDetailViewController = segue.destination as? MealDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }

            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }

            let selectedMeal = meals[indexPath.row]
            // segue.destination.meal
            mealDetailViewController.meal = selectedMeal
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
            
        }
        
    }
    
    
    // MARK: Actions
    
    // 新規オブジェクトの追加　もしオブジェクトの編集をするのであればデータを呼び出す
    // unwindtoMealList は目的地に記述する モーダルのリターン先
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        // source 遷移元　がダウンキャストできるか？
        if let sourceViewController = sender.source as? MealDetailViewController, let meal = sourceViewController.meal {
            
            // データの追加insertRows orデータの更新reloadRows
            // データの編集時は値が入り、　新規＋からの時はnilが入る
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                // 更新
                // meals配列とTableViewのリスト
                meals[selectedIndexPath.row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
                
            } else {
                // Add a new meal.
                // 新規作成
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                meals.append(meal)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            // エンコード　meals配列
            // Save the meals.
            saveMeals()
        }
    }
    
    // MARK: Private Methods
    private func loadSampleMeals() {
        let photo1 = #imageLiteral(resourceName: "meal1")
        let photo2 = #imageLiteral(resourceName: "meal2")
        let photo3 = #imageLiteral(resourceName: "meal3")
        
        // Mealクラスの初期化関数initは オプショナル型なのでnilで返ってくる場合をguardで除く
        guard let meal1 = Meal(name: "Hamburger", photo: photo1, rating: 4) else {
            fatalError("Unable to instantiate meal1")
        }
        
        guard let meal2 = Meal(name: "Hamburger", photo: photo2, rating: 5) else {
            fatalError("Unable to instantiate meal2")
        }
        
        guard let meal3 = Meal(name: "Hamburger", photo: photo3, rating: 3) else {
            fatalError("Unable to instantiate meal3")
        }
        
        meals += [meal1, meal2, meal3]
    }
    
    private func saveMeals() {
        // 保存　NSKeyedArchiver
        guard let archivedData = try? NSKeyedArchiver.archivedData(withRootObject: meals, requiringSecureCoding: false) else {
            fatalError("Unable to archive meals")
        }
        
        do {
            // 保存する　エラーは例外処理
            try archivedData.write(to: Meal.ArchiveURL)
            os_log("Meals successfully saved.", log: OSLog.default, type: .debug)
        } catch {
            os_log("Failed to save meals...", log: OSLog.default, type: .error)
        }
    }
    
    private func loadMeals() -> [Meal]? {
        // 保存先から読み出す
        do {
            let data = try Data.init(contentsOf: Meal.ArchiveURL)
            if let loadedData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Meal] {
                os_log("Meals successfully loaded.", log: OSLog.default, type: .debug)
                return loadedData
            }
        } catch {
            os_log("Failed to load meals...", log: OSLog.default, type: .error)
        }
        return nil
    }
}
