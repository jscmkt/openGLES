var loginTemp = `<div id="login">
<div id="windows">
    <div><span id="cancel">X</span></div>
    <div id="edge">
        <h1>用户登录</h1>
        <hr/>
        <label for="">
            <span>用户名</span>
            <input type="text" name="user" id="user">
        </label>
        <label for="">
            <span>密码</span>
            <input type="password" name="pass" id="pass">
        </label>
        <p id="button">
            <button id="loginSubmission" type="button">提交</button>
        </p>
    <div>
</div>
</div>`;
var regTemp = `<div id="login">
<div id="windows">
    <div><span id="cancel">X</span></div>
    <div id="edge">
        <h1>用户注册</h1>
        <hr/>
        <label for="">
            <span>用户名</span>
            <input type="text" name="user" id="user">
        </label>
        <label for="">
            <span>密码</span>
            <input type="password" name="pass" id="pass">
        </label>
        <label for="">
            <span>重复密码</span>
            <input type="password" name="rptpass" id="rptpass">
        </label>
        <label for="">
            <span>手机号码</span>
            <input type="text" name="phone" id="phone">
        </label>
        <p id="button">
         <a target="_blank" href="/file/html/serviceAgreement.html">用户协议</a>
         <input type="checkbox" name="checkbox" checked  id="checkbox">
         <button id="regSubmission" type="button">提交</button>
        </p>
    <div>
</div>
</div>`


$(() => {
    var user = sessionStorage.getItem('userName');
    if (user) {
        $('.top').find('span').empty().append(`欢迎 ${user} 用户登录 <a href="javascript:void(0)" class='out'>退出</a>`);
    }
    $('.top').on('click', '.out', () => {
        sessionStorage.clear();
        location.reload();
    })
    $('.login').on('click', () => {
        $('body').append(loginTemp);
    })

    $('.reg').on('click', () => {
        $('body').append(regTemp);


    })
    $('body').on('click', '#cancel', () => {
        $('#login').remove();
    });



    $("body").on('click', '#loginSubmission', () => {
        var user = $('#user').val();
        var pass = $('#pass').val();
        if (!user) {
            alert('用户名不能为空');
            return;
        }
        if (!pass) {
            alert('密码不能为空');
            return;
        }
        var data = { 'user': user, 'pass': pass };
        $.ajax({
            type: "post",
            data: data,
            url: '/login/',
            dataType: 'JSON',
            success: mes => {
                if (mes.data == 1) {
                    $('.top').find('span').empty().append(`欢迎 ${user} 用户登录 <a href="javascript:void(0)" class='out'>退出</a>`);
                    sessionStorage.setItem('userName', user);
                    $('#login').remove();
                }
                if (mes.data == 0) {
                    alert('登录失败');
                }
            },
            xhrFields: {
                withCredentials: true,
            },
        })
        $('#login').remove();
    });


    $("body").on('click', '#regSubmission', () => {
        var checkbox = $('#checkbox')
        var user = $('#user').val();
        var pass = $('#pass').val();
        var rptpass = $('#rptpass').val();
        var phone = $('#phone').val();
        var data = { 'user': user, 'pass': pass, 'rptpass': rptpass, 'phone': phone };
        if (!checkbox.prop("checked")) {
            alert('确认用户协议');
            return;
        }

        if (!user) {
            alert('用户名不能为空');
            return;
        }
        if (!pass) {
            alert('密码不能为空');
            return;
        }
        if (!rptpass) {
            alert('重复密码不能为空');
            return;
        }
        if (!(rptpass == pass)) {
            alert('重复密码与密码不一致');
            return;
        }
        if (!phone) {
            alert('手机号不能为空');
            return;
        }
        if (!(/^1[3456789]\d{9}$/.test(phone))) {
            alert("手机号码有误，请重填");
            return false;
        }



        $.ajax({
            type: "post",
            data: data,
            url: '/register/',
            dataType: 'JSON',
            success: mes => {
                if (mes.data == 1) {
                    alert('注册成功');
                    $('.top').find('span').empty().append(`欢迎 ${user} 用户登录 <a href="javascript:void(0)" class='out'>退出</a>`);
                    sessionStorage.setItem('userName', user);
                    $('#login').remove();
                }
                if (mes.data == 0) {
                    alert('注册失败');
                }
            },
            xhrFields: {
                withCredentials: true,
            },
        })
        $('#login').remove();
    })
})
