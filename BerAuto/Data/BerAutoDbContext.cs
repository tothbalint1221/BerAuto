using BerAuto.Models;
using Microsoft.EntityFrameworkCore;

namespace BerAuto.Data;

public partial class BerAutoDbContext : DbContext
{
    public BerAutoDbContext()
    {
    }

    public BerAutoDbContext(DbContextOptions<BerAutoDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Car> Cars { get; set; }

    public virtual DbSet<Invoice> Invoices { get; set; }

    public virtual DbSet<Rental> Rentals { get; set; }

    public virtual DbSet<User> Users { get; set; }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
#warning To protect potentially sensitive information in your connection string, you should move it out of source code. You can avoid scaffolding the connection string by using the Name= syntax to read it from configuration - see https://go.microsoft.com/fwlink/?linkid=2131148. For more guidance on storing connection strings, see https://go.microsoft.com/fwlink/?LinkId=723263.
        => optionsBuilder.UseSqlServer("Server=(localdb)\\MSSQLLocalDB;Database=BerAutoDb;Trusted_Connection=True;TrustServerCertificate=True");

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Car>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Cars__3214EC07E4204A5B");

            entity.Property(e => e.Brand).HasMaxLength(100);
            //entity.Property(e => e.Category).HasMaxLength(20);
            entity.Property(e => e.Category)
                      .HasConversion<string>()
                      .HasMaxLength(20);
            entity.Property(e => e.DailyPrice).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.IsAvailable).HasDefaultValue(true);
            entity.Property(e => e.Model).HasMaxLength(100);
        });

        modelBuilder.Entity<Invoice>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Invoices__3214EC07BDC97422");

            entity.HasIndex(e => e.RentalId, "IX_Invoices_RentalId");

            entity.HasIndex(e => e.RentalId, "UQ__Invoices__970059427C6649F6").IsUnique();

            entity.Property(e => e.Amount).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.IssueDate).HasColumnType("datetime");
            entity.Property(e => e.UpdatedAt).HasColumnType("datetime");

            entity.HasOne(d => d.Rental).WithOne(p => p.Invoice)
                .HasForeignKey<Invoice>(d => d.RentalId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Invoices_Rentals");
        });

        modelBuilder.Entity<Rental>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Rentals__3214EC07A4E20F8D");

            entity.HasIndex(e => e.CarId, "IX_Rentals_CarId");

            entity.HasIndex(e => e.UserId, "IX_Rentals_UserId");

            entity.Property(e => e.CreatedAt)
                .HasDefaultValueSql("(getdate())")
                .HasColumnType("datetime");
            entity.Property(e => e.EndDate).HasColumnType("datetime");
            entity.Property(e => e.StartDate).HasColumnType("datetime");
            //entity.Property(e => e.Status).HasMaxLength(20);
            entity.Property(e => e.Status)
                            .HasConversion<string>()
                            .HasMaxLength(20);
            entity.Property(e => e.TotalCost).HasColumnType("decimal(10, 2)");
            entity.Property(e => e.UpdatedAt).HasColumnType("datetime");

            entity.HasOne(d => d.Car).WithMany(p => p.Rentals)
                .HasForeignKey(d => d.CarId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Rentals_Cars");

            entity.HasOne(d => d.User).WithMany(p => p.Rentals)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_Rentals_Users");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.HasKey(e => e.Id).HasName("PK__Users__3214EC07DED82622");

            entity.HasIndex(e => e.Email, "UX_Users_Email_NotNull")
                .IsUnique()
                .HasFilter("([Email] IS NOT NULL)");

            entity.Property(e => e.Address).HasMaxLength(250);
            entity.Property(e => e.Email).HasMaxLength(150);
            entity.Property(e => e.IsRegistered).HasDefaultValue(true);
            entity.Property(e => e.Name).HasMaxLength(150);
            entity.Property(e => e.PasswordHash).HasMaxLength(300);
            entity.Property(e => e.PhoneNumber).HasMaxLength(50);
            //entity.Property(e => e.Role).HasMaxLength(20);
            entity.Property(e => e.Role)
                            .HasConversion<string>()
                            .HasMaxLength(20);
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
