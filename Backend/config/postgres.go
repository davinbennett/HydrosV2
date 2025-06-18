package config

import (
	"fmt"
	"log"
	"os"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var PostgresDB *gorm.DB

func ConnectPostgres() error {
	dsn := fmt.Sprintf(
		"host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=Asia/Jakarta",
		os.Getenv("POSTGRES_HOST"),
		os.Getenv("POSTGRES_USER"),
		os.Getenv("POSTGRES_PASSWORD"),
		os.Getenv("POSTGRES_DB"),
		os.Getenv("POSTGRES_PORT"),
	)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}

	sqlDB, err := db.DB()
	if err != nil {
		return fmt.Errorf("failed to get database instance: %w", err)
	}

	if err := sqlDB.Ping(); err != nil {
		return fmt.Errorf("failed to ping database: %w", err)
	}

	PostgresDB = db
	log.Println("✅ Successfully connected to PostgreSQL!")
	return nil
}

func AutoMigrate(models ...interface{}) error {
    if PostgresDB == nil {
        return fmt.Errorf("database connection not initialized")
    }

    debugDB := PostgresDB.Debug()

    log.Println("Starting database migration...")
    for _, model := range models {
        log.Printf("Migrating model: %T", model)
    }

    if err := debugDB.AutoMigrate(models...); err != nil {
        return fmt.Errorf("failed to auto migrate: %w", err)
    }

    log.Println("✅ Migration completed successfully!")
    for _, model := range models {
        var count int64
        debugDB.Model(model).Count(&count)
        log.Printf("Table %T now has %d records", model, count)
    }

    return nil
}
