from flask import Flask, render_template, redirect, url_for, request, flash, session
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
from flask_wtf import FlaskForm
from wtforms import StringField, PasswordField, SubmitField
from wtforms.validators import DataRequired, Length, EqualTo , IPAddress
import pymysql
from flask_wtf import FlaskForm



app = Flask(__name__)

# 配置
app.config['SECRET_KEY'] = 'your_very_secure_secret_key_here'
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:123456@localhost/user_auth'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False



# 初始化扩展
db = SQLAlchemy(app)
bcrypt = Bcrypt(app)

# 用户模型
class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)
    iot_client = db.Column(db.String(20))
    iot_server = db.Column(db.String(20))

    def __repr__(self):
        return f'<User {self.username}>'

# 表单类
class RegistrationForm(FlaskForm):
    username = StringField('用户名', validators=[
        DataRequired('用户名不能为空'),
        Length(min=3, max=50, message='用户名长度需在3-50个字符之间')
    ])
    password = PasswordField('密码', validators=[
        DataRequired('密码不能为空'),
        Length(min=6, max=100, message='密码长度需在6-100个字符之间')
    ])
    confirm_password = PasswordField('确认密码', validators=[
        DataRequired('请确认密码'),
        EqualTo('password', message='两次输入的密码不一致')
    ])
    submit = SubmitField('注册')

class LoginForm(FlaskForm):
    username = StringField('用户名', validators=[
        DataRequired('请输入用户名')
    ])
    password = PasswordField('密码', validators=[
        DataRequired('请输入密码')
    ])
    submit = SubmitField('登录')


class DashboardForm(FlaskForm):
    # 注意：这里字段名必须与模板中的 name 属性一致
    iot_client = StringField('IoT 客户端IP地址', validators=[DataRequired()])
    iot_server = StringField('IoT 服务器IP地址', validators=[DataRequired()])
    submit1 = SubmitField('应用配置')
    submit2 = SubmitField('刷新配置')
    Select = SubmitField('1')

# 路由
@app.route('/')
def index():
    #if 'username' in session:
       # return redirect(url_for('dashboard'))
    return render_template('index.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if 'username' in session:
        return redirect(url_for('dashboard'))
    
    form = RegistrationForm()
    if form.validate_on_submit():
        # 检查用户名是否已存在
        existing_user = User.query.filter_by(username=form.username.data).first()
        if existing_user:
            flash('该用户名已被使用，请选择其他用户名', 'danger')
            return redirect(url_for('register'))
        
        # 加密密码
        hashed_password = bcrypt.generate_password_hash(form.password.data).decode('utf-8')
        
        # 创建新用户
        new_user = User(username=form.username.data, password=hashed_password)
        db.session.add(new_user)
        db.session.commit()
        
        flash(f'账号 {form.username.data} 注册成功！现在可以登录了', 'success')
        return redirect(url_for('login'))
    
    return render_template('register.html', form=form)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if 'username' in session:
        return redirect(url_for('dashboard'))
    
    form = LoginForm()
    if form.validate_on_submit():
        user = User.query.filter_by(username=form.username.data).first()
        
        if user and bcrypt.check_password_hash(user.password, form.password.data):
            # 登录成功，设置会话
            session['user_id'] = user.id
            session['username'] = user.username
            flash('登录成功！', 'success')
            return redirect(url_for('dashboard'))
        else:
            flash('用户名或密码错误，请重试', 'danger')
    
    return render_template('login.html', form=form)

@app.route('/dashboard',methods=['GET', 'POST'])
def dashboard():
    if 'username' not in session:
        flash('请先登录', 'warning')
        return redirect(url_for('login'))
    
    
    user = User.query.filter_by(username=session['username']).first()
    # 创建表单实例
    form = DashboardForm()
    render_template('dashboard.html', username=session['username'],form=form) 
    if form.validate_on_submit():
         # 获取用户提交的IoT参数
        iot_client = form.iot_client.data
        iot_server = form.iot_server.data
        user.iot_client = iot_client
        user.iot_server = iot_server
        db.session.commit()
        flash('IoT配置已成功更新!', 'success')

    form.iot_client.data = user.iot_client or ''
    form.iot_server.data = user.iot_server or ''

    # 确保将 form 传递给模板
    return render_template('dashboard.html', username=session['username'],form=form) 


@app.route('/logout')
def logout():
    session.pop('user_id', None)
    session.pop('username', None)
    flash('您已成功登出', 'info')
    return redirect(url_for('index'))

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)