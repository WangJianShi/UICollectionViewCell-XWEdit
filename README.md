# UICollectionViewCell-XWEdit
类似UITableViewCell滑动删除（Switf）
可高度自定义滑动出现的视图
使用便捷(代码如下)

注：xw_rightEidtView，xw_leftEidtView为cell扩展的属性

        let view: UIView = UIView.init(frame: CGRect.zero)
        view.backgroundColor = UIColor.red
        let btn: UIButton = UIButton.init(frame: CGRect.zero)
        btn.setTitle("删除", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        view.addSubview(btn)
        btn.snp.makeConstraints({ (make) in
            
            make.center.equalTo(btn.superview!);
            make.left.equalTo(btn.superview!).offset(25);
            make.right.equalTo(btn.superview!).offset(-25);
        })
        
        self.xw_rightEidtView = deleteView
