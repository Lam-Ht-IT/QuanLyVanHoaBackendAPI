﻿using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Newtonsoft.Json;
using QUANLYVANHOA.Interfaces;
using Microsoft.Data.SqlClient;
using System.Security.Claims;

public class CustomAuthorizeAttribute : AuthorizeAttribute, IAuthorizationFilter
{
    private readonly int _requiredPermission;
    private readonly string _requiredFunction;

    public CustomAuthorizeAttribute(int permission, string functionName)
    {
        _requiredPermission = permission;
        _requiredFunction = functionName;
    }

    public void OnAuthorization(AuthorizationFilterContext context)
    {
        if (!context.HttpContext.User.Identity.IsAuthenticated)
        {
            context.Result = new UnauthorizedResult();
            return;
        }

        // Manually resolve the service (e.g., IUserService) using HttpContext.RequestServices
        // Giải quyết thủ công service (vd: IUserService) bằng HttpContext.RequestServices
        var userService = context.HttpContext.RequestServices.GetService<IUserService>();

        if (userService == null)
        {
            context.Result = new ForbidResult();
            return;
        }

        // Lấy các claim từ token
        var claimsIdentity = context.HttpContext.User.Identity as ClaimsIdentity;
        var permissionsClaim = claimsIdentity?.FindFirst("FunctionsAndPermissions");

        if (permissionsClaim == null)
        {
            context.Result = new ForbidResult();
            return;
        }

        // Parse JSON từ claim thành dictionary
        var permissions = JsonConvert.DeserializeObject<Dictionary<string, int>>(permissionsClaim.Value);

        // Kiểm tra quyền của người dùng đối với chức năng yêu cầu
        if (!permissions.ContainsKey(_requiredFunction) || (permissions[_requiredFunction] & _requiredPermission) != _requiredPermission)
        {
            context.Result = new ForbidResult();
            return;
        }
    }


    public static Dictionary<string, int> GetAllUserFunctionsAndPermissions(string userName)
    {
        var permissions = new Dictionary<string, int>();

        //using (SqlConnection conn = new SqlConnection("Server=192.168.100.129;Database=DB_QuanLyVanHoa;User Id=The Debuggers;Password=ifyouwanttoconnectyouneedtobecomeaprofessionalprogrammer;"))
        using (SqlConnection conn = new SqlConnection(new Connection().GetConnectionString()))

        {
            conn.Open();
            SqlCommand cmd = new SqlCommand("NhomChucNang_GetAllUserFunctionsAndPermissions", conn);
            cmd.CommandType = System.Data.CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@TenNguoiDung", userName);

            using (var reader = cmd.ExecuteReader())
            {
                while (reader.Read())
                {
                    // Thêm chức năng và quyền vào dictionary
                    string functionName = reader.GetString(0);
                    int permission = reader.GetInt32(1);
                    permissions[functionName] = permission;
                }
            }
        }
        return permissions;
    }

}