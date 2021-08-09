import UIKit
import RealmSwift
import DropDown
import UserNotifications    // 追加

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UIGestureRecognizerDelegate{
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchCategory: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    
    // Realmインスタンスを取得する
    var realm = try! Realm()  // ←追加
    let dropDown = DropDown()
    var categoryArray = try! Realm().objects(Category.self) // ←追加
    
    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)  // ←追加

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
       // searchCategory.delegate = self
        
        if categoryArray.count == 0 {
            var category = Category()
            try! realm.write {
            category.name = "Business"
            self.realm.add(category, update: .modified)
            }
            categoryArray = try! Realm().objects(Category.self) // ←追加
            category = Category()
            try! realm.write {
            category.id = categoryArray.max(ofProperty: "id")! + 1
            category.name = "Private"
            self.realm.add(category, update: .modified)
            }
            categoryArray = try! Realm().objects(Category.self) // ←追加
            category = Category()
            try! realm.write {
            category.id = categoryArray.max(ofProperty: "id")! + 1
            category.name = "Other"
            self.realm.add(category, update: .modified)
            }
            categoryArray = try! Realm().objects(Category.self) // ←追加
        }
        
        searchCategory?.text = ""
        let tapAction:UITapGestureRecognizer = UITapGestureRecognizer(
        target: self,
        action: #selector(ViewController.tapped(_:)))
        searchCategory?.isUserInteractionEnabled = true
        searchCategory?.addGestureRecognizer(tapAction)
        }
    
    @objc func tapped(_ sender: UITapGestureRecognizer){
        if sender.state == .ended {
            dropDown.show()
        }
    }
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count  // ←修正する
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Cellに値を設定する.  --- ここから ---
        let task = taskArray[indexPath.row]
        print(task)
        cell.textLabel?.text = task.title

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        // --- ここまで追加 ---

        return cell
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil) // ←追加する
    }

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // --- ここから ---
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]

            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        } // --- ここまで変更 ---
    }
    
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:inputViewController = segue.destination as! inputViewController

        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()

            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }

    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        categoryArray = try! Realm().objects(Category.self) // ←追加
        dropDown.anchorView = searchCategory
        dropDown.dataSource = Array(categoryArray).map { $0.name }
        dropDown.direction = .bottom
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            
            searchCategory.text = item
            print(searchCategory.text!)
            
            if searchCategory.text == ""{
               taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)  // ←追加
            } else {
               categoryArray = try! Realm().objects(Category.self)
               .filter("name == %@", item)
                taskArray = realm
               .objects(Task.self)
               .filter("category == %@", categoryArray[0])
            }
            tableView.reloadData()
            
        }
        tableView.reloadData()
        
    }
       
    @IBAction func resetButtonPush(_ sender: Any) {
        searchCategory?.text = ""
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)  // ←追加
        tableView.reloadData()
        
    }
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
}

