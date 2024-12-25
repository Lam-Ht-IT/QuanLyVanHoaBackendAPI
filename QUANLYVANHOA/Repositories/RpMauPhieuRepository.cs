﻿using QUANLYVANHOA.Interfaces;
using Newtonsoft.Json;
using System.Data.SqlClient;
using System.Data;
using QUANLYVANHOA.Models;

namespace QUANLYVANHOA.Repositories
{
    public class RpMauPhieuRepository : IRpMauPhieuRepository
    {
        private readonly Connection _connectionString;

        public RpMauPhieuRepository(IConfiguration configuration)
        {
            _connectionString = new Connection();
        }

        public async Task<(IEnumerable<RpMauPhieu>, int)> GetAllMauPhieu(string? name, int pageNumber, int pageSize)
        {
            var rpMauPhieuList = new List<RpMauPhieu>();
            int totalRecords = 0;
            using (var connection = new SqlConnection(_connectionString.GetConnectionString()))
            {
                using (var command = new SqlCommand("MP_GetAll", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TenMauPhieu", name);
                    command.Parameters.AddWithValue("@PageNumber", pageNumber);
                    command.Parameters.AddWithValue("@PageSize", pageSize);

                    await connection.OpenAsync();

                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        while (await reader.ReadAsync())
                        {
                            rpMauPhieuList.Add(new RpMauPhieu
                            {
                                MauPhieuID = reader.GetInt32(reader.GetOrdinal("MauPhieuID")),
                                TenMauPhieu = reader.GetString(reader.GetOrdinal("TenMauPhieu")),
                                LoaiMauPhieuID = reader.GetInt32(reader.GetOrdinal("LoaiMauPhieuID")),
                                MaMauPhieu = reader.GetString(reader.GetOrdinal("MaMauPhieu")),
                                NgayTao = reader.GetDateTime(reader.GetOrdinal("NgayTao")),
                                NguoiTao = reader.GetString(reader.GetOrdinal("NguoiTao"))
                            });

                            
                        }
                        await reader.NextResultAsync();
                        if (await reader.ReadAsync())
                        {
                            totalRecords = reader.GetInt32(reader.GetOrdinal("TotalRecords"));
                        }
                    }
                }
            }
            return (rpMauPhieuList, totalRecords);
        }

        public async Task<RpMauPhieu> GetMauPhieuByID(int id)
        {
            RpMauPhieu mauPhieu = null;
            using (var connection = new SqlConnection(_connectionString.GetConnectionString()))
            {
                using (var command = new SqlCommand("MP_GetByID", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@MauPhieuID", id);

                    await connection.OpenAsync();
                    using (var reader = await command.ExecuteReaderAsync())
                    {
                        // Đọc thông tin mẫu phiếu chính
                        if (await reader.ReadAsync())
                        {
                            mauPhieu = new RpMauPhieu
                            {
                                MauPhieuID = reader.GetInt32(reader.GetOrdinal("MauPhieuID")),
                                TenMauPhieu = reader.GetString(reader.GetOrdinal("TenMauPhieu")),
                                MaMauPhieu = reader.GetString(reader.GetOrdinal("MaMauPhieu")),
                                LoaiMauPhieuID = reader.GetInt32(reader.GetOrdinal("LoaiMauPhieuID")),
                                NgayTao = reader.GetDateTime("NgayTao"),
                                NguoiTao = reader.GetString(reader.GetOrdinal("NguoiTao")),
                                //Allow null KyBaoCaoID & ThangBaoCao
                                KyBaoCaoID = reader.GetInt32(reader.GetOrdinal("KyBaoCaoID")),
                                ThangBaoCao = reader.IsDBNull(reader.GetOrdinal("ThangBaoCao")) ? null : reader.GetString(reader.GetOrdinal("ThangBaoCao")),
                                // Lấy trực tiếp chuỗi JSON
                                ChiTieuS = reader.IsDBNull(reader.GetOrdinal("ChiTieuS")) ? null : reader.GetString(reader.GetOrdinal("ChiTieuS")),
                                TieuChiS = reader.IsDBNull(reader.GetOrdinal("TieuChiS")) ? null : reader.GetString(reader.GetOrdinal("TieuChiS"))
                            };
                        }

                        // Đọc danh sách các chi tiết mẫu phiếu nếu có
                        if (await reader.NextResultAsync())
                        {
                            mauPhieu.ChiTietMauPhieus = new List<RpChiTietMauPhieu>();
                            while (await reader.ReadAsync())
                            {
                                mauPhieu.ChiTietMauPhieus.Add(new RpChiTietMauPhieu
                                {
                                    ChiTietMauPhieuID = reader.GetInt32(reader.GetOrdinal("ChiTietMauPhieuID")),
                                    MauPhieuID = reader.GetInt32(reader.GetOrdinal("MauPhieuID")),
                                    ChiTieuID = reader.GetInt32(reader.GetOrdinal("ChiTieuID")),
                                    TieuChiIDs = reader.GetString(reader.GetOrdinal("TieuChiIDs")), // Deserialize từ chuỗi thành List<int>
                                    NoiDung = reader.IsDBNull(reader.GetOrdinal("NoiDung")) ? null : reader.GetString(reader.GetOrdinal("NoiDung")),
                                    GopCot = reader.GetBoolean(reader.GetOrdinal("GopCot")),
                                    GopTuCot = reader.GetInt32(reader.GetOrdinal("GopTuCot")),
                                    GopDenCot = reader.GetInt32(reader.GetOrdinal("GopDenCot")),
                                    SoCotGop = reader.GetInt32(reader.GetOrdinal("SoCotGop"))       
                                    
                                });
                            }
                        }
                    }
                }
            }
            return mauPhieu;
        }

        // Thêm mới mẫu phiếu
        public async Task<int> CreateMauPhieu(RpMauPhieuInsertModel mauPhieu)
        {
            using (var connection = new SqlConnection(_connectionString.GetConnectionString()))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("MP_Create", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@TenMauPhieu", mauPhieu.TenMauPhieu);
                    command.Parameters.AddWithValue("@LoaiMauPhieuID", mauPhieu.LoaiMauPhieuID);
                    command.Parameters.AddWithValue("@MaMauPhieu", mauPhieu.MaMauPhieu);
                    command.Parameters.AddWithValue("@NguoiTao", mauPhieu.NguoiTao);
                    command.Parameters.AddWithValue("@KyBaoCaoID", mauPhieu.KyBaoCaoID);
                    command.Parameters.AddWithValue("@ThangBaoCao", mauPhieu.ThangBaoCao);

                    // Truyền xuống dữ liệu JSON string
                    command.Parameters.AddWithValue("@ChiTieus", JsonConvert.SerializeObject(mauPhieu.ChiTieuS));
                    command.Parameters.AddWithValue("@TieuChis", JsonConvert.SerializeObject(mauPhieu.TieuChiS));
                    command.Parameters.AddWithValue("@ChiTietMauPhieuS", JsonConvert.SerializeObject(mauPhieu.ChiTietMauPhieus));
                    return await command.ExecuteNonQueryAsync();
                }
            }
        }

        public async Task<int> UpdateMauPhieu(RpMauPhieuUpdateModel mauPhieu)
        {
            using (var connection = new SqlConnection(_connectionString.GetConnectionString()))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("MP_Update", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;

                    // Add parameters
                    command.Parameters.AddWithValue("@MauPhieuID", mauPhieu.MauPhieuID);
                    command.Parameters.AddWithValue("@TenMauPhieu", mauPhieu.TenMauPhieu);
                    command.Parameters.AddWithValue("@MaMauPhieu", mauPhieu.MaMauPhieu);
                    command.Parameters.AddWithValue("@LoaiMauPhieuID", mauPhieu.LoaiMauPhieuID);
                    command.Parameters.AddWithValue("@KyBaoCaoID", mauPhieu.KyBaoCaoID);
                    command.Parameters.AddWithValue("@ThangBaoCao", mauPhieu.ThangBaoCao);
                    command.Parameters.AddWithValue("@NguoiTao", mauPhieu.NguoiTao);
                    command.Parameters.AddWithValue("@ChiTieus", JsonConvert.SerializeObject(mauPhieu.ChiTieuS));
                    command.Parameters.AddWithValue("@TieuChis", JsonConvert.SerializeObject(mauPhieu.TieuChiS));
                    command.Parameters.AddWithValue("@ChiTietMauPhieus", JsonConvert.SerializeObject(mauPhieu.ChiTietMauPhieus));

                    return await command.ExecuteNonQueryAsync();
                }
            }
        }

        public async Task<int> DeleteMauPhieu(int id)
        {
            int result = 0;

            using (var connection = new SqlConnection(_connectionString.GetConnectionString()))
            {
                await connection.OpenAsync();
                using (var command = new SqlCommand("MP_Delete", connection))
                {
                    command.CommandType = CommandType.StoredProcedure;
                    command.Parameters.AddWithValue("@MauPhieuID", id);

                    try
                    {
                        result = await command.ExecuteNonQueryAsync();
                    }
                    catch (Exception ex)
                    {
                        // Handle the exception or rethrow
                        throw;
                    }
                }
            }

            return result;
        }

    }
}
