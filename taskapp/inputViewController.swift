//
//  inputViewController.swift
//  taskapp
//
//  Created by dslog sys on 2021/07/31.
//

import UIKit
import RealmSwift    // 追加する
import DropDown //ドロップダウンリスト追加

class inputViewController: UIViewController,UITextFieldDelegate{

    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
 
    var task: Task!
    let realm = try! Realm()    // 追加する
        
    let dropDown = DropDown()
    var categoryArray = try! Realm().objects(Category.self) // ←追加
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        categoryTextField.delegate = self

        categoryTextField.text = ""
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
 
        let category = Category()
        if categoryArray.count == 0 {
            try! realm.write {
            category.name = "Business"
            self.realm.add(category, update: .modified)
            category.name = "Private"
            self.realm.add(category, update: .modified)
            category.name = "Other"
            self.realm.add(category, update: .modified)
            }
        }
        
        categoryArray = try! Realm().objects(Category.self) // ←追加
        //let view = UIView()
        dropDown.anchorView = categoryTextField
        dropDown.dataSource = Array(categoryArray).map { $0.name }
        print( Array(categoryArray))
        dropDown.direction = .bottom
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            categoryTextField.text = item
        }
    }
    
    // 追加する
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.category?.name = ""
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: .modified)
        }
        setNotification(task: task)   // 追加 ローカル通知
        super.viewWillDisappear(animated)
    }
    // タスクのローカル通知を登録する --- ここから ---
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default

        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)

        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }

        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    } // --- ここまで追加 ---
    
    @IBAction func tapCategory(_ sender: UITextField) {
        dropDown.show()
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
