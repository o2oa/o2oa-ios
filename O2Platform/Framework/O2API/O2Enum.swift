//
//  O2Enum.swift
//  O2OA_SDK_Framwork
//
//  Created by FancyLou on 2018/11/14.
//

import Foundation



/// O2OA 服务端 API 模块列表
///
/// - x_processplatform_assemble_surface_script:
/// - x_processplatform_assemble_surface_task:
/// - x_processplatform_assemble_surface_worklog:
/// - x_processplatform_assemble_surface_workcompleted:
/// - x_processplatform_assemble_surface_attachment:
/// - x_processplatform_assemble_surface_work:
/// - x_file_assemble_control: //云文件
/// - x_pan_assemble_control: //云文件V3
/// - x_meeting_assemble_control: //会议管理
/// - x_attendance_assemble_control: //考勤管理
/// - x_okr_assemble_control: //OKR
/// - x_bbs_assemble_control: //BBS
/// - x_hotpic_assemble_control: //热图展现
/// - x_processplatform_assemble_surface_applicationdict: //数据字典模块
/// - x_cms_assemble_control:
/// - x_organization_assemble_control: //新组织人员管理
/// - x_collaboration_assemble_websocket:
/// - x_organization_assemble_custom:
/// - x_processplatform_assemble_surface:
/// - x_processplatform_assemble_surface_read:
/// - x_processplatform_assemble_surface_readcompleted:
/// - x_organization_assemble_express:
/// - x_organization_assemble_personal:
/// - x_processplatform_assemble_surface_taskcompleted:
/// - x_processplatform_assemble_surface_process:
/// - x_component_assemble_control:
/// - x_processplatform_assemble_surface_application:
/// - x_processplatform_assemble_surface_data:
/// - x_processplatform_assemble_designer:
/// - x_processplatform_assemble_surface_review:
/// - x_organization_assemble_authentication: //认证模块
/// - x_portal_assemble_surface: //门户模块
/// - x_calendar_assemble_control: //日程
/// - x_jpush_assemble_control:  //极光推送
/// - x_query_assemble_surface:  //数据查询
/// - x_mind_assemble_control:  //脑图
public enum O2ModuleContext {
    case x_processplatform_assemble_surface_script
    case x_processplatform_assemble_surface_task
    case x_processplatform_assemble_surface_worklog
    case x_processplatform_assemble_surface_workcompleted
    case x_processplatform_assemble_surface_attachment
    case x_processplatform_assemble_surface_work
    case x_file_assemble_control
    case x_pan_assemble_control
    case x_meeting_assemble_control
    case x_attendance_assemble_control
    case x_okr_assemble_control
    case x_bbs_assemble_control
    case x_hotpic_assemble_control
    case x_processplatform_assemble_surface_applicationdict
    case x_cms_assemble_control
    case x_organization_assemble_control
    case x_collaboration_assemble_websocket
    case x_organization_assemble_custom
    case x_processplatform_assemble_surface
    case x_processplatform_assemble_surface_read
    case x_processplatform_assemble_surface_readcompleted
    case x_organization_assemble_express
    case x_organization_assemble_personal
    case x_processplatform_assemble_surface_taskcompleted
    case x_processplatform_assemble_surface_process
    case x_component_assemble_control
    case x_processplatform_assemble_surface_application
    case x_processplatform_assemble_surface_data
    case x_processplatform_assemble_designer
    case x_processplatform_assemble_surface_review
    case x_organization_assemble_authentication
    case x_portal_assemble_surface
    case x_calendar_assemble_control
    case x_jpush_assemble_control
    case x_query_assemble_surface
    case x_organizationPermission // custom模块 通讯录 需要到应用市场下载安装
    case x_mind_assemble_control // 脑图

}

/// 启动过程状态
///
/// - success: 成功 进入到主页
/// - loginError: 登录失败，需要去登录页面
/// - bindError: 绑定验证失败，需要去绑定页面
/// - unknownError: 未知错误，可能是服务器不通等 无法进入应用
public enum O2LaunchProcessState {
    case success
    case loginError
    case bindError
    case unknownError
}


enum O2AuthError: Error {
    case blockError(String)
    case noBindError // 没有绑定信息
    case bindExpireError // 绑定已经过期
    case noLoginError // 没有登录
}

/// 绑定手机过程状态
///
/// - success: 成功进入主页
/// - goToLogin: 需要去登录页面
/// - goToChooseBindServer: 有多个unit，需要去选择页面选择要绑定的unit
/// - noUnitCanBindError: 没有可以绑定的服务器
/// - unknownError: 未知错误
public enum O2BindProcessState {
    case success
    case goToLogin
    case goToChooseBindServer([O2BindUnitModel])
    case noUnitCanBindError
    case unknownError
}

/// 绑定中断情况
///
/// - tooManyUnitError: 有多个单位，需要去选择页面选择绑定的单位
/// - noLoginError: 需要去登录页面 重新登录
/// - noUnitCanBindError：当前手机号码没有可以绑定的服务器
enum O2BindDiscontinue: Error {
    case tooManyUnit([O2BindUnitModel])
    case noLoginError(String)
    case noUnitCanBindError
    case unknownError(String)
}

/// 首页 的 5个页面
enum MainPageType {
    case home
    case im
    case contact
    case app
    case settings
}
extension MainPageType {
    func getKey() -> String {
        switch(self) {
        case .home:
            return "home"
        case .im:
            return "im"
        case .contact:
            return "contact"
        case .app:
            return "app"
        case .settings:
            return "settings"
        }
    }
    
    func getOrder() -> Int {
        switch(self) {
        case .home:
            return 1
        case .im:
            return 2
        case .contact:
            return 3
        case .app:
            return 4
        case .settings:
            return 5
        }
    }
}
